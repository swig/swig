import sys
import inspect

if sys.version_info[0:2] >= (3, 2):
    from python_annotations_typing import *

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
        anno = get_annotations(MakeShort)
        if anno != {"x": "int"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(global_ints)
        if anno != {}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        ts = MakeShort(10)

        anno = get_annotations(MakeShort)
        if anno != {"x": "int"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(ts.mymethod)
        if anno != {"arg2": "int", "return": "None"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        # No annotations
        anno = get_annotations(no_annotations)
        if anno != {}:
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        def make_argcheck(exp, args):
            d = {arg: exp for arg in args}
            d["return"] = "None"
            return d

        anno = get_annotations(argcheck_bool)
        if anno != make_argcheck("bool", ["a_bool"]):
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations( argcheck_char)
        if anno != make_argcheck("str", ["a_char", "a_wchar"]):
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations(argcheck_int)
        if anno != make_argcheck("int", [
            "a_schar", "a_uchar", "a_short", "a_ushort","a_int",
            "a_uint", "a_long", "a_ulong", "a_llong", "a_ullong"
        ]):
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations(argcheck_float)
        if anno != make_argcheck("float", ["a_float", "a_double"]):
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations(argcheck_str)
        if anno != make_argcheck("str", ["a_cstr", "a_wcstr"]):
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations(use_callable)
        if anno != {"return": "None", "c": "typing.Callable[[]]"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))
