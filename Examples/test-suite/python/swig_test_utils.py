import ast
import contextlib
import inspect
import os
import random
import string
import sys

import typing


def swig_assert(condition, msg="Assertion failed"):
    """Variant of `assert` that is not disabled by the -O flag"""
    if not condition:
        raise AssertionError(msg)

def swig_check(lhs, rhs):
    """More user friendly assert function which shows values in an AssertionError if they are not equal"""
    if not lhs == rhs:
        raise AssertionError("'{lhs}' != '{rhs}', repr(lhs)={lr}, repr(rhs)={rr}".format(lhs=lhs, rhs=rhs, lr=repr(lhs), rr=repr(rhs)))


def swig_annotations_in_stub():
    """Return whether generated annotations are stored in a .pyi stub."""
    return "-pyi" in os.environ.get("SWIG_FEATURES", "").split()


def _swig_stub_annotation_text(annotation):
    """Return the text represented by a generated stub annotation AST node."""
    value = getattr(annotation, "value", None)
    if isinstance(value, str):
        return value
    value = getattr(annotation, "s", None)
    if isinstance(value, str):
        return value
    if isinstance(annotation, ast.Name):
        return annotation.id
    raise RuntimeError("unexpected annotation in generated stub: {}".format(ast.dump(annotation)))


def _swig_stub_lookup(tree: ast.Module, names: typing.List[str]):
    """Find the AST declaration for a list of nested names, or None if absent."""
    node = tree
    for name in names:
        matches = [
            child
            for child in node.body
            if isinstance(child, (ast.ClassDef, ast.FunctionDef)) and child.name == name
        ]
        if not matches:
            return None
        node = matches[-1]
    return node


def _swig_stub_is_overload(node: ast.FunctionDef):
    return any(
        isinstance(attr, ast.Attribute)
        and isinstance(attr.value, ast.Name)
        and attr.value.id == "typing"
        and attr.attr == "overload"
        for attr in node.decorator_list
    )


def _swig_stub_lookup_overloads(tree: ast.Module, names: typing.List[str]):
    """Find the AST declaration for a list of nested names, or None if absent."""
    node = tree
    for name in names[:-1]:
        matches = [
            child
            for child in node.body
            if isinstance(child, ast.ClassDef) and child.name == name
        ]
        if not matches:
            return []
        node = matches[-1]
    return [
        child
        for child in node.body
        if isinstance(child, ast.FunctionDef)
        if child.name == names[-1] and _swig_stub_is_overload(child)
    ]


def _swig_split_flat_name(tree, names):
    """Split a flat -fastproxy method name, Class_method, into its stub class and method names."""
    for child in tree.body:
        if isinstance(child, ast.ClassDef) and names[0].startswith(child.name + "_"):
            return [child.name, names[0][len(child.name) + 1:]] + names[1:]
    return names


def _swig_stub_node(tree: ast.Module, qualified_name: str, fastproxy: bool):
    """Find the AST declaration for a qualified name in a generated stub."""
    names = qualified_name.split(".")
    if fastproxy:
        # With -fastproxy a method is the flat C wrapper function, so its
        # __qualname__ is Class_method rather than Class.method. Module level
        # functions keep their plain name, so only split names not found as is.
        if _swig_stub_lookup(tree, names) is None:
            names = _swig_split_flat_name(tree, names)
    node = _swig_stub_lookup(tree, names)
    if node is None:
        raise RuntimeError("{} is missing from generated stub".format(qualified_name))
    return node


def _swig_stub_overloads(tree: ast.Module, qualified_name: str, fastproxy: bool):
    names = qualified_name.split(".")
    overloads = _swig_stub_lookup_overloads(tree, names)
    if fastproxy and overloads == []:
        names = _swig_split_flat_name(tree, names)
        overloads = _swig_stub_lookup_overloads(tree, names)
    return overloads


def _swig_get_ast_node_annotations(
    node: typing.Union[ast.Module, ast.ClassDef, ast.FunctionDef],
):
    annotations = {}
    for child in node.body:
        if isinstance(child, ast.AnnAssign) and isinstance(child.target, ast.Name):
            value = getattr(child.annotation, "value", None)
            is_string = isinstance(value, str)
            if child.annotation.__class__.__name__ == "Str":
                is_string = isinstance(getattr(child.annotation, "s", None), str)
            if is_string:
                annotations[child.target.id] = _swig_stub_annotation_text(
                    child.annotation
                )

    if isinstance(node, ast.FunctionDef):
        arguments = (
            getattr(node.args, "posonlyargs", [])
            + node.args.args
            + node.args.kwonlyargs
        )
        if node.args.vararg:
            arguments.append(node.args.vararg)
        if node.args.kwarg:
            arguments.append(node.args.kwarg)
        for argument in arguments:
            if argument.annotation:
                annotations[argument.arg] = _swig_stub_annotation_text(
                    argument.annotation
                )
        if node.returns:
            annotations["return"] = _swig_stub_annotation_text(node.returns)

    return annotations


def swig_get_annotations(obj, module_name, fastproxy=False):
    """Return the annotations for a generated Python object.

    When SWIG_FEATURES contains -pyi, read the annotations from the generated
    ``module_name + ".pyi"`` stub. Otherwise, read annotations attached to the
    runtime object, using inspect.get_annotations() when available and falling
    back to __annotations__ on older Python versions.

    Args:
        obj: Generated module, class, or function to inspect.
        module_name: Generated module name used to locate its .pyi file.
        fastproxy: True when the module was generated with -fastproxy, as the
            proxy methods are then named after the flat C wrapper functions
            rather than after the methods in the stub.

    Returns:
        A dictionary mapping annotated names to their annotation values.
    """
    if not swig_annotations_in_stub():
        if hasattr(inspect, "get_annotations"):
            return inspect.get_annotations(obj)  # python 3.10 added inspect.get_annotations
        return getattr(obj, "__annotations__", {})  # python 3.14 removed __annotations__

    with open(module_name + ".pyi") as stub_file:
        tree = ast.parse(stub_file.read(), filename=stub_file.name)

    node = tree if inspect.ismodule(obj) else _swig_stub_node(tree, obj.__qualname__, fastproxy)
    return _swig_get_ast_node_annotations(node)


def swig_can_get_overloads():
    return swig_annotations_in_stub() or hasattr(typing, "get_overloads")


def swig_get_overload_annotations(obj, module_name, fastproxy=False):
    if not swig_annotations_in_stub():
        # typing.get_overloads() was added in Python 3.11.
        if not hasattr(typing, "get_overloads"):
            raise RuntimeError("Missing typing.get_overloads")
        return [inspect.get_annotations(i) for i in typing.get_overloads(obj)]

    with open(module_name + ".pyi") as stub_file:
        tree = ast.parse(stub_file.read(), filename=stub_file.name)

    overloads = _swig_stub_overloads(tree, obj.__qualname__, fastproxy)
    return [_swig_get_ast_node_annotations(i) for i in overloads]


@contextlib.contextmanager
def swig_assert_raises(exc_cls):
    """Reimplementation of pytest.raises context manager."""
    try:
        yield
    except exc_cls:
        pass
    else:
        raise AssertionError("{} was not raised".format(exc_cls.__name__))


def swig_random_string(length=None):
    if length is None:
        length = random.randint(0, 16)
    domain = string.ascii_letters + string.digits
    if sys.version_info < (3, 6):
        chars = [random.choice(domain) for _ in range(length)]
    else:
        chars = random.choices(domain, k=length)
    return "".join(chars)


def swig_run_threaded(
    func,
    max_workers=8,
    pass_count=False,
    pass_barrier=False,
    outer_iterations=1,
    prepare_args=None,
):
    """Runs a function many times in parallel.
    Copied from numpy/testing/_private/utils.py::run_threaded
    """
    import concurrent.futures
    import threading

    for _ in range(outer_iterations):
        executor = concurrent.futures.ThreadPoolExecutor(max_workers=max_workers)
        with executor as tpe:
            if prepare_args is None:
                args = []
            else:
                args = prepare_args()
            if pass_barrier:
                barrier = threading.Barrier(max_workers)
                args.append(barrier)
            if pass_count:
                all_args = [[func, i] + args for i in range(max_workers)]
            else:
                all_args = [[func] + args for _ in range(max_workers)]
            try:
                futures = []
                for arg in all_args:
                    futures.append(tpe.submit(*arg))
            except RuntimeError as e:
                print(
                    "Spawning {} threads failed with "
                    "error {} (likely due to resource limits on the "
                    "system running the tests)".format(max_workers, e)
                )
            finally:
                if len(futures) < max_workers and pass_barrier:
                    barrier.abort()
            for f in futures:
                f.result()
