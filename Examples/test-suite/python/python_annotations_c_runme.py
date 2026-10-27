from swig_test_utils import (
    swig_annotations_in_stub,
    swig_can_get_overloads,
    swig_check,
    swig_get_annotations,
    swig_get_overload_annotations,
)
from python_annotations_c import *

# Annotations are only added to the runtime objects for the default proxy classes,
# but with -pyi they are always available in the generated .pyi stub file
annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_c", is_python_fastproxy())

def check_overloads(fn, expected):
    if len(expected) > 0:
        if swig_annotations_in_stub():
            # Ensure that there's no declaration without @tying.overload.
            # mypy doesn't like that: "An implementation for an overloaded function is not allowed in a stub file".
            swig_check(get_annotations(fn), None)
        else:
            # There are some overloads, ensure that the actual function doesn't have any annotations.
            swig_check(get_annotations(fn), {})

    if not swig_can_get_overloads():
        return

    swig_check(
        swig_get_overload_annotations(
            fn, "python_annotations_c", is_python_fastproxy()
        ),
        expected
    )


if annotations_supported:
    anno = get_annotations(MakeShort)
    if anno != {'x': 'int', 'return': 'Space::Template< short >'}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(global_ints)
    if anno != {'ri': 'int &', 't': 'TemplateShort', 'return': 'int *'}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    ts = MakeShort(10)

    anno = get_annotations(MakeShort)
    if anno != {'x': 'int', 'return': 'Space::Template< short >'}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(ts.mymethod)
    if anno != {'arg2': 'int', 'tt': 'TemplateShort', 'return': 'void'}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    # No annotations
    anno = get_annotations(no_annotations)
    if anno != {}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    check_overloads(
        global_overloaded,
        [
            {
                "ri": "int &",
                "return": "int *",
            },
            {"return": "int *"},
        ],
    )

    # Overloads returning different types have no one C/C++ type to be annotated with
    check_overloads(
        global_overloaded_differ,
        [
            {"x": "int", "return": "int"},
            {"x": "double", "y": "double", "return": "double"},
        ],
    )

    # numoutputs=0 in the out typemap leaves nothing to return, annotated as void
    anno = get_annotations(suppressed_none)
    if anno != {'code': 'int', 'return': 'void'}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(suppressed_none(0), None)

    # with an argout typemap the argout type is annotated, as it always was
    anno = get_annotations(suppressed_one)
    if anno != {'code': 'int', 'return': 'short *'}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(suppressed_one(0), 42)

# C/C++ annotations are not type hints and are never type checked, so none of the PEP 484 machinery is generated.
# A quoted "typing.Any" is an annotation; the unquoted one is the placeholder a .pyi needs for an unannotated name.
# The feature is applied per declaration here rather than to the whole module, so the class is not itself C/C++
# annotated and declares thisown with the catch-all type as any other class does. python_annotations_variable_c
# applies the feature to the whole module and so has no such declaration to skip.
generated = ["python_annotations_c.py"]
if swig_annotations_in_stub():
    generated.append("python_annotations_c.pyi")
for filename in generated:
    with open(filename) as f:
        source = "".join(line for line in f if "thisown" not in line)
    for unwanted in ("_swig_property", "_swig_dispatch", "TYPE_CHECKING", '"typing.Any"'):
        if unwanted in source:
            raise RuntimeError("{} should not contain {}".format(filename, unwanted))
