import sys

# Variable annotations for properties is only supported in python-3.6 and later (PEP 526)
if sys.version_info[0:2] >= (3, 6):
    from python_annotations_variable_c import *

    # No SWIG __annotations__ support with -builtin or -fastproxy
    annotations_supported = not(is_python_builtin() or is_python_fastproxy())

    if annotations_supported:
        ts = TemplateShort()
        anno = ts.__annotations__
        if anno != {'member_variable': 'int'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        ts = StructWithVar()
        anno = ts.__annotations__
        if anno != {'member_variable': 'int'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        ts = StructWithVarNotAnnotated()
        if getattr(ts, "__annotations__", None) != None:
            anno = ts.__annotations__
            raise RuntimeError("annotations mismatch: {}".format(anno))
