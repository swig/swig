import ast
import sys

from swig_test_utils import swig_annotations_in_stub, swig_get_annotations


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_variable_typing", is_python_fastproxy())


# Variable annotations for properties is only supported in python-3.6 and later (PEP 526)
if sys.version_info[0:2] >= (3, 6):
    import python_annotations_variable_typing
    from python_annotations_variable_typing import *

    # Annotations are only added to the runtime objects for the default proxy classes,
    # but with -pyi they are always available in the generated .pyi stub file
    annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())

    if annotations_supported:
        expected = {
            "A_CONSTANT_INT": "int",
            "A_CONSTANT_SHORT": "int",
        }
        # The .pyi stub file declares the global variables holder, which the .py file assigns
        if swig_annotations_in_stub():
            expected["cvar"] = "typing.Any"
        anno = get_annotations(python_annotations_variable_typing)
        if anno != expected:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(TemplateShort)
        if anno != {'member_variable': 'int'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(StructWithVar)
        if anno != {'member_variable': 'int'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(StructWithVarNotAnnotated)
        if anno != {}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

    # 'this' is a variable annotation, so novar turns it off along with the others, keeping the
    # generated code free of the PEP 526 syntax that requires Python 3.6. -builtin has no proxy classes.
    with open("python_annotations_variable_typing.py") as f:
        tree = ast.parse(f.read(), filename="python_annotations_variable_typing.py")

    def declares_this(class_name):
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef) and node.name == class_name:
                return any(isinstance(x, ast.AnnAssign) and getattr(x.target, "id", None) == "this"
                           for x in ast.walk(node))
        return None

    if declares_this("StructWithVar") is not None:
        if not declares_this("StructWithVar"):
            raise RuntimeError("StructWithVar should declare 'this'")
        if declares_this("StructNovar"):
            raise RuntimeError("StructNovar is novar so it should not declare 'this'")
