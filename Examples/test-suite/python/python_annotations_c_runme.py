from swig_test_utils import swig_annotations_in_stub, swig_get_annotations

from python_annotations_c import *

# No __annotations__ support with -builtin or -fastproxy
annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_c")

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
