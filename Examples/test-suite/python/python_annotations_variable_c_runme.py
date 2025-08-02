import sys
import inspect


def get_annotations(cls):
    # Python >=3.14 removed the __annotations__ attribute
    # retrieve it via inspect (see also annotationlib)
    if hasattr(inspect, "get_annotations"):
        # Python >=3.10
        return inspect.get_annotations(cls)
    else:
        # Python <3.10
        return getattr(cls, "__annotations__", {})


# Variable annotations for properties is only supported in python-3.6 and later (PEP 526)
if sys.version_info[0:2] >= (3, 6):
    from python_annotations_variable_c import *

    # No SWIG __annotations__ support with -builtin or -fastproxy
    annotations_supported = not(is_python_builtin() or is_python_fastproxy())

    if annotations_supported:
        anno = get_annotations(TemplateShort)
        if anno != {'member_variable': 'int'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(StructWithVar)
        if anno != {'member_variable': 'int'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(StructWithVarNotAnnotated)
        if anno != {}:
            raise RuntimeError("annotations mismatch: {}".format(anno))
