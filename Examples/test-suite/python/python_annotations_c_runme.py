from swig_test_utils import swig_annotations_in_stub, swig_check, swig_get_annotations

from python_annotations_c import *

# Annotations are only added to the runtime objects for the default proxy classes,
# but with -pyi they are always available in the generated .pyi stub file
annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_c", is_python_fastproxy())

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
