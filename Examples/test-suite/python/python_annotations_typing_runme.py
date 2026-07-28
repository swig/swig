from swig_test_utils import swig_annotations_in_stub, swig_assert, swig_check, swig_get_annotations

from python_annotations_typing import *

# Annotations are only added to the runtime objects for the default proxy classes,
# but with -pyi they are always available in the generated .pyi stub file
annotations_supported = swig_annotations_in_stub() or not(is_python_builtin() or is_python_fastproxy())


def get_annotations(obj):
    return swig_get_annotations(obj, "python_annotations_typing", is_python_fastproxy())

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

    anno = get_annotations(take_argv)
    if anno != {"argc": "typing.List[str]", "return": "None"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(take_argv_surround)
    if anno != {
        "before": "float",
        "argc": "typing.List[str]",
        "after": "int",
        "return": "None",
    }:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    def make_argcheck(exp, args):
        d = {arg: exp for arg in args}
        d["return"] = "None"
        return d

    anno = get_annotations(argcheck_bool)
    if anno != make_argcheck("bool", ["a_bool", "a_bool_cref"]):
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(argcheck_char)
    if anno != make_argcheck("str", ["a_char", "a_wchar", "a_char_cref"]):
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(argcheck_int)
    if anno != make_argcheck(
        "int",
        [
            "a_schar",
            "a_uchar",
            "a_short",
            "a_ushort",
            "a_int",
            "a_uint",
            "a_long",
            "a_ulong",
            "a_llong",
            "a_ullong",
            "a_size",
            "a_stdsize",
            "a_ptrdiff",
            "a_stdptrdiff",
            "a_short_cref",
            "a_int_cref",
            "a_size_cref",
            "a_stdsize_cref",
            "a_ptrdiff_cref",
            "a_stdptrdiff_cref",
        ],
    ):
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(argcheck_float)
    if anno != make_argcheck("float", ["a_float", "a_double", "a_double_cref"]):
        raise RuntimeError("annotations mismatch: {}".format(anno))

    # long double has no in/out typemaps of its own, so it is wrapped as a pointer
    anno = get_annotations(argcheck_long_double)
    if anno != make_argcheck(
        "SWIGTYPE_p_long_double", ["a_ldouble", "a_ldouble_cref"]
    ):
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(argcheck_complex)
    if anno != make_argcheck(
        "complex", ["a_cfloat", "a_cdouble", "a_cdouble_cref"]
    ):
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(argcheck_str)
    if anno != {
        "a_cstr": "typing.Optional[str]",
        "a_wcstr": "typing.Optional[str]",
        "a_stdstr": "str",
        "a_stdwstr": "str",
        "a_stdstr_cref": "str",
        "return": "None",
    }:
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

    # $*pytypename removes one pointer level: MyStruct ** -> MyStruct proxy name.
    anno = get_annotations(use_deref)
    if anno != {"return": "None", "pp": "typing.Optional[MyStruct]"}:
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

    # A pytyping typemap using $pytypename should expand to int.
    anno = get_annotations(use_pytypename_enum)
    if anno != {"return": "None", "e": "typing.Optional[int]"}:
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

    anno = get_annotations(make_short_ref)
    if anno != {"return": "SWIGTYPE_p_short"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(make_short_cref)
    if anno != {"return": "int"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(make_struct_ref)
    if anno != {"return": "MyStruct"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    anno = get_annotations(make_struct_cref)
    if anno != {"return": "MyStruct"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    # Class-typed member variables are wrapped as annotated properties.
    anno = get_annotations(HasClassMembers)
    if anno != {"member_value": "MyStruct", "member_pointer": "typing.Optional[MyStruct]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    # A forward-declared-only class has no proxy, so $pytypename falls back
    # to an opaque type wrapper class.
    anno = get_annotations(use_forward_only)
    if anno != {"return": "None", "fp": "typing.Optional[SWIGTYPE_p_ForwardOnly]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))

    import python_annotations_typing

    # A class-typed %constant is annotated at module level.
    if get_annotations(python_annotations_typing).get("CONST_STRUCT") != "typing.Optional[MyStruct]":
        raise RuntimeError("annotations mismatch: {}".format(get_annotations(python_annotations_typing)))

    # The type wrapper classes referenced by the annotations above (the
    # SWIGTYPE_* opaque types) are declared only for static type checkers
    # under 'if typing.TYPE_CHECKING' and must not exist at runtime.
    for name in [
        "SWIGTYPE_p_void", "SWIGTYPE_p_int", "SWIGTYPE_p_short",
        "SWIGTYPE_p_float", "SWIGTYPE_p_f_char_bool__int",
        "SWIGTYPE_p_ForwardOnly",
    ]:
        swig_assert(not hasattr(python_annotations_typing, name))

    anno = get_annotations(argoutVoidSingleReplace)
    if anno != {"arg": "bool", "return": "int"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutVoidSingleReplace(True), int))

    anno = get_annotations(argoutVoidSingleAppend)
    if anno != {"arg": "bool", "return": "int"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutVoidSingleAppend(True), int))

    anno = get_annotations(argoutBoolSingleReplace)
    if anno != {"arg": "bool", "return": "int"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutBoolSingleReplace(True), int))

    anno = get_annotations(argoutBoolSingleAppend)
    if anno != {"arg": "bool", "return": "typing.List[typing.Union[bool, int]]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutBoolSingleAppend(True), list))

    anno = get_annotations(argoutVoidAppendTwice)
    if anno != {"arg": "bool", "return": "typing.List[typing.Union[int, int]]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutVoidAppendTwice(True), list))

    anno = get_annotations(argoutBoolAppendTwice)
    if anno != {"arg": "bool", "return": "typing.List[typing.Union[bool, int, int]]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutBoolAppendTwice(True), list))
    anno = get_annotations(argoutVoidReplaceTwice)
    if anno != {"arg": "bool", "return": "int"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutVoidReplaceTwice(True), int))

    anno = get_annotations(argoutBoolTuple)
    if anno != {"arg": "bool", "return": "typing.Tuple[bool,float]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutBoolTuple(True), tuple))

    anno = get_annotations(argoutBoolTupleTwice)
    if anno != {"arg": "bool", "return": "typing.Tuple[bool,float,float]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutBoolTupleTwice(True), tuple))

    anno = get_annotations(argoutMultiarg)
    if anno != {"return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutMultiarg(), list))

    anno = get_annotations(argoutMultiargReplace)
    if anno != {"return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_assert(isinstance(argoutMultiarg(), list))

    anno = get_annotations(argoutBoolMultiarg)
    if anno != {"arg": "bool", "return": "typing.List[typing.Union[bool, typing.List[int]]]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutBoolMultiarg(True), [True, []])

    anno = get_annotations(argoutBoolMultiargReplace)
    if anno != {"arg": "bool", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutBoolMultiargReplace(True), [])

    anno = get_annotations(argoutMultiargAfterFirst)
    if anno != {"first": "int", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutMultiargAfterFirst(1), [])

    anno = get_annotations(argoutMultiargReplaceAfterFirst)
    if anno != {"first": "int", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutMultiargReplaceAfterFirst(1), [])

    anno = get_annotations(argoutBoolMultiargAfterFirst)
    if anno != {"first": "int", "return": "typing.List[typing.Union[bool, typing.List[int]]]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutBoolMultiargAfterFirst(2), [True, []])

    anno = get_annotations(argoutBoolMultiargReplaceAfterFirst)
    if anno != {"first": "int", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutBoolMultiargReplaceAfterFirst(2), [])

    anno = get_annotations(argoutMultiargBetweenFirstLast)
    if anno != {"first": "int", "last": "float", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutMultiargBetweenFirstLast(3, 4.0), [])

    anno = get_annotations(argoutMultiargReplaceBetweenFirstLast)
    if anno != {"first": "int", "last": "float", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutMultiargReplaceBetweenFirstLast(3, 4.0), [])

    anno = get_annotations(argoutBoolMultiargBetweenFirstLast)
    if anno != {"first": "int", "last": "float", "return": "typing.List[typing.Union[bool, typing.List[int]]]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutBoolMultiargBetweenFirstLast(5, 6.0), [True, []])

    anno = get_annotations(argoutBoolMultiargReplaceBetweenFirstLast)
    if anno != {"first": "int", "last": "float", "return": "typing.List[int]"}:
        raise RuntimeError("annotations mismatch: {}".format(anno))
    swig_check(argoutBoolMultiargReplaceBetweenFirstLast(5, 6.0), [])
