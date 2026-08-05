from swig_test_utils import swig_annotations_in_stub, swig_get_annotations

from python_annotations_import_b import *

# Annotations are only added to the runtime objects for the default proxy classes,
# but with -pyi they are always available in the generated .pyi stub file
annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_import_b", is_python_fastproxy())

if annotations_supported:
    # Klass is defined in the imported module python_annotations_import_a, so
    # $pytypename must expand to the module-qualified proxy name.
    anno = get_annotations(use_imported)
    if anno != {
        "k": "typing.Optional[python_annotations_import_a.Klass]",
        "return": "None",
    }:
        raise RuntimeError("annotations mismatch: {}".format(anno))
