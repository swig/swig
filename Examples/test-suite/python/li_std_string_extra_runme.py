from swig_test_utils import swig_get_annotations

import li_std_string_extra

x = "hello"


if li_std_string_extra.test_ccvalue(x) != x:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_cvalue(x) != x:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_value(x) != x:
    raise RuntimeError("bad string mapping {} {}".format(x, li_std_string_extra.test_value(x)))

if li_std_string_extra.test_const_reference(x) != x:
    raise RuntimeError("bad string mapping")

s = li_std_string_extra.string("1234567890")
size = s.size()
if size != 10:
    raise "Incorrect size"
s.shrink_to_fit()

s = li_std_string_extra.string("he")
#s += "ll"
# s.append("o")
s = s + "llo"

if s != x:
    raise RuntimeError("bad string mapping {} {}".format(s, x))

if s[1:4] != x[1:4]:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_value(s) != x:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_const_reference(s) != x:
    raise RuntimeError("bad string mapping")

a = li_std_string_extra.A(s)

if li_std_string_extra.test_value(a) != x:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_const_reference(a) != x:
    raise RuntimeError("bad string mapping")

b = li_std_string_extra.string(" world")

s = a + b
if a + b != "hello world":
    raise RuntimeError("bad string mapping {}".format(a + b))

if a + " world" != "hello world":
    raise RuntimeError("bad string mapping")

# This is expected to fail with -builtin option
# Reverse operators not supported in builtin types
if not li_std_string_extra.is_python_builtin():
    if "hello" + b != "hello world":
        raise RuntimeError("bad string mapping")

    c = "hello" + b
    if c.find_last_of("l") != 9:
        raise RuntimeError("bad string mapping")

s = "hello world"

b = li_std_string_extra.B("hi")

b.name = li_std_string_extra.string("hello")
if b.name != "hello":
    raise RuntimeError("bad string mapping")


b.a = li_std_string_extra.A("hello")
if b.a != "hello":
    raise RuntimeError("bad string mapping")


if li_std_string_extra.test_value_basic1(x) != x:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_value_basic2(x) != x:
    raise RuntimeError("bad string mapping")


if li_std_string_extra.test_value_basic3(x) != x:
    raise RuntimeError("bad string mapping")

if li_std_string_extra.test_value_basic_overload(x) != x:
    raise RuntimeError("bad overload string")

if li_std_string_extra.test_value_basic_overload(123) != "int":
    raise RuntimeError("bad overload int")

try:
    li_std_string_extra.test_value_basic_overload([x])
    raise RuntimeError("should throw TypeError")
except TypeError as e:
    if str(e).find("Possible C/C++ prototypes are:") == -1:
        raise RuntimeError("Incorrect error message text:\n{}".format(e))
    pass

try:
    li_std_string_extra.test_value_basic_overload([123])
    raise RuntimeError("should throw TypeError")
except TypeError as e:
    if str(e).find("Possible C/C++ prototypes are:") == -1:
        raise RuntimeError("Incorrect error message text:\n{}".format(e))
    pass

# Global variables
s = "initial string"
if li_std_string_extra.cvar.GlobalString2 != "global string 2":
    raise RuntimeError("GlobalString2 test 1")
li_std_string_extra.cvar.GlobalString2 = s
if li_std_string_extra.cvar.GlobalString2 != s:
    raise RuntimeError("GlobalString2 test 2")
if li_std_string_extra.cvar.ConstGlobalString != "const global string":
    raise RuntimeError("ConstGlobalString test")

# Member variables
myStructure = li_std_string_extra.Structure()
if myStructure.MemberString2 != "member string 2":
    raise RuntimeError("MemberString2 test 1")
myStructure.MemberString2 = s
if myStructure.MemberString2 != s:
    raise RuntimeError("MemberString2 test 2")
if myStructure.ConstMemberString != "const member string":
    raise RuntimeError("ConstMemberString test")

if li_std_string_extra.cvar.Structure_StaticMemberString2 != "static member string 2":
    raise RuntimeError("StaticMemberString2 test 1")
li_std_string_extra.cvar.Structure_StaticMemberString2 = s
if li_std_string_extra.cvar.Structure_StaticMemberString2 != s:
    raise RuntimeError("StaticMemberString2 test 2")
if li_std_string_extra.cvar.Structure_ConstStaticMemberString != "const static member string":
    raise RuntimeError("ConstStaticMemberString test")


if li_std_string_extra.test_reference_input("hello") != "hello":
    raise RuntimeError
s = li_std_string_extra.test_reference_inout("hello")
if s != "hellohello":
    raise RuntimeError


if li_std_string_extra.stdstring_empty() != "":
    raise RuntimeError


if li_std_string_extra.c_empty() != "":
    raise RuntimeError

if li_std_string_extra.c_null() != None:
    raise RuntimeError


def get_annotations(obj):
    return swig_get_annotations(obj, "li_std_string_extra", li_std_string_extra.is_python_fastproxy())


def check_annotations(obj, expected):
    anno = get_annotations(obj)
    if anno != expected:
        raise RuntimeError("annotations mismatch: {}".format(anno))


# The basic_string methods are annotated str only where they are converted to and from a Python str.
# Annotations are only generated with -typehints, hence checking that there are some at all first.
if get_annotations(li_std_string_extra.string.substr):
    # Returned by value, so converted to a str
    check_annotations(li_std_string_extra.string.substr, {"return": "str"})
    check_annotations(li_std_string_extra.string.__str__, {"return": "str"})

    # Returned as a pointer to the proxy class rather than converted to a str
    check_annotations(li_std_string_extra.string.__add__, {"v": "typing.Any", "return": "typing.Any"})

    # __eq__ accepts any object, so must not be annotated with the type the C++ takes
    check_annotations(li_std_string_extra.string.__eq__, {"v": "typing.Any", "return": "bool"})

    # An instantiation that is not converted to a str keeps the catch-all type
    check_annotations(li_std_string_extra.MyString.substr, {"return": "typing.Any"})
