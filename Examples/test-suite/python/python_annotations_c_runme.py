import sys

if sys.version_info[0:2] >= (3, 2):
    from python_annotations_c import *

    # No __annotations__ support with -builtin or -fastproxy
    annotations_supported = not(is_python_builtin() or is_python_fastproxy())

    if annotations_supported:
        anno = MakeShort.__annotations__
        if anno != {'x': 'int', 'return': 'Space::Template< short >'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = global_ints.__annotations__
        if anno != {'ri': 'int &', 't': 'TemplateShort', 'return': 'int *'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        ts = MakeShort(10)

        anno = MakeShort.__annotations__
        if anno != {'x': 'int', 'return': 'Space::Template< short >'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = ts.mymethod.__annotations__
        if anno != {'arg2': 'int', 'tt': 'TemplateShort', 'return': 'void'}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        # No annotations
        anno = no_annotations.__annotations__
        if anno != {}:
            raise RuntimeError("annotations mismatch: {}".format(anno))
