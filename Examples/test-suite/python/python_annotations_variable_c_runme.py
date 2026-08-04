import sys

from swig_test_utils import swig_annotations_in_stub, swig_get_annotations


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_variable_c", is_python_fastproxy())


# Variable annotations for properties is only supported in python-3.6 and later (PEP 526)
if sys.version_info[0:2] >= (3, 6):
    import python_annotations_variable_c
    from python_annotations_variable_c import *

    # Annotations are only added to the runtime objects for the default proxy classes,
    # but with -pyi they are always available in the generated .pyi stub file
    annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())

    if annotations_supported:
        anno = get_annotations(python_annotations_variable_c)
        if anno != {
            "A_CONSTANT_INT": "int",
            "A_CONSTANT_SHORT": "short",
        }:
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
