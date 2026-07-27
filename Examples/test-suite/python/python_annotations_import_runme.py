import inspect

from python_annotations_import_b import *

# No __annotations__ support with -builtin or -fastproxy
annotations_supported = not(is_python_builtin() or is_python_fastproxy())

def get_annotations(cls):
    # Python >=3.14 removed the __annotations__ attribute
    # retrieve it via inspect (see also annotationlib)
    if hasattr(inspect, "get_annotations"):
        # Python >=3.10
        return inspect.get_annotations(cls)
    else:
        # Python <3.10
        return getattr(cls, "__annotations__", {})

if annotations_supported:
    # Klass is defined in the imported module python_annotations_import_a, so
    # $pytypename must expand to the module-qualified proxy name.
    anno = get_annotations(use_imported)
    if anno != {
        "k": "typing.Optional[python_annotations_import_a.Klass]",
        "return": "None",
    }:
        raise RuntimeError("annotations mismatch: {}".format(anno))
