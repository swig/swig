import sys
import inspect
from swig_test_utils import swig_assert

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
        anno = get_annotations(global_ints)
        if anno != {
            "ri": "SWIGTYPE_p_int",
            "t": "TemplateShort",
            "return": "typing.Optional[SWIGTYPE_p_int]",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations(global_overloaded)
        if anno != {"return": "typing.Optional[SWIGTYPE_p_int]"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        ts = MakeShort(10)

        anno = get_annotations(MakeShort)
        if anno != {"x": "int", "return": "TemplateShort"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(ts.mymethod)
        if anno != {
            "arg2": "int",
            "tt": "typing.Optional[TemplateShort]",
            "return": "None",
        }:
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
        
        anno = get_annotations(argcheck_fnptr)
        if anno != make_argcheck("typing.Optional[SWIGTYPE_p_f_char_bool__int]", ["f"]):
            raise RuntimeError("annotations mismatch: {}".format(anno))
        
        anno = get_annotations(argcheck_array)
        if anno != make_argcheck("typing.Optional[SWIGTYPE_p_float]", ["arr"]):
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(optional_square)
        if anno != {"return": "typing.Optional[int]", "i": "typing.Optional[int]"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        swig_assert(optional_square(None) is None)
        swig_assert(optional_square(3) == 9)

        anno = get_annotations(docs_do_something_out_type)
        if anno != {"return": "int", "t": "typing.Union[int, float]"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        my_struct = MyStruct()

        anno = get_annotations(my_struct.do_something)
        if anno != {
            "return": "None",
            "ref": "MyStruct",
            "ptr": "typing.Optional[MyStruct]",
            "cref": "MyStruct",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(use_typedefs)
        if anno != {
            "return": "None",
            "i": "int",
            "mt": "int",
            "cref_mst": "MyStruct",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(use_memberfn_ptr)
        if anno != {
            "return": "None",
            "ptr": "typing.Optional[SWIGTYPE_m_MyStruct__f_r_MyStruct_p_MyStruct_r_q_const__MyStruct__void]",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(use_member_ptr)
        if anno != {
            "return": "None",
            "ptr": "typing.Optional[SWIGTYPE_m_OptionalInt__int]",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(use_enums)
        if anno != {
            "return": "None",
            "me": "bool",
            "met": "bool",
            "moe": "int",
            "moet": "int",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(use_namespaced)
        if anno != {
            "return": "None",
            "ns1": "MyNamespaced1",
            "inner1": "MyInner",
            "inner_ns1": "typing.Optional[MyNamespaced2]",
        }:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        anno = get_annotations(wrap_ptr)
        if anno != {"return": "typing.Optional[SWIGTYPE_p_void]", "val": "int"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))
        anno = get_annotations(unwrap_ptr)
        if anno != {"ptr": "typing.Optional[SWIGTYPE_p_void]", "return": "int"}:
            raise RuntimeError("annotations mismatch: {}".format(anno))

        assert wrap_ptr(0) is None
        assert unwrap_ptr(None) == 0
        assert unwrap_ptr(wrap_ptr(0)) == 0
        assert wrap_ptr(1) is not None
        assert unwrap_ptr(wrap_ptr(1)) == 1
