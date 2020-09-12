import li_std_wstring
import sys

def check_equal(a, b):
    if a != b:
        raise RuntimeError("failed {} {}".format(a, b))

h = "h"
check_equal(li_std_wstring.test_wcvalue(h), h)

x = "abc"
check_equal(li_std_wstring.test_ccvalue(x), x)
check_equal(li_std_wstring.test_cvalue(x), x)

check_equal(li_std_wstring.test_wchar_overload(x), x)
check_equal(li_std_wstring.test_wchar_overload(), None)

li_std_wstring.test_pointer(None)
li_std_wstring.test_const_pointer(None)

try:
    li_std_wstring.test_value(None)
    raise RuntimeError("NULL check failed")
except TypeError as e:
    pass

try:
      li_std_wstring.test_reference(None)
      raise RuntimeError("NULL check failed")
except ValueError as e:
    if "invalid null reference" not in str(e):
        raise RuntimeError("Missing text {}".format(e))
try:
    li_std_wstring.test_const_reference(None)
    raise RuntimeError("NULL check failed")
except ValueError as e:
    if "invalid null reference" not in str(e):
        raise RuntimeError("Missing text {}".format(e))

x = "hello"
check_equal(li_std_wstring.test_const_reference(x), x)

s = "abc"
if not li_std_wstring.test_equal_abc(s):
    raise RuntimeError("Not equal {}".format(s))

try:
    li_std_wstring.test_throw
except RuntimeError as e:
    check_equal(e.message, "throwing test_throw")

x = "abc\0def"
check_equal(li_std_wstring.test_value(x), x)
check_equal(li_std_wstring.test_ccvalue(x), "abc")
check_equal(li_std_wstring.test_wchar_overload(x), "abc")

ts = li_std_wstring.wchar_test_struct()
ts.wchar_t_member = h
check_equal(ts.wchar_t_member, h)
ts.wchar_t_ptr_member = s
check_equal(ts.wchar_t_ptr_member, s)

################### Python specific

# Byte strings only converted in Python 2
if sys.version_info[0:2] < (3, 0):
    x = b"hello there"
    if li_std_wstring.test_value(x) != x:
        raise RuntimeError("bad string mapping")

# Invalid utf-8 in a byte string fails in all versions
x = b"h\xe9llo"
try:
    li_std_wstring.test_value(x)
    raise RuntimeError("TypeError not thrown")
except TypeError:
    pass

# Check surrogateescape
if sys.version_info[0:2] > (3, 1):
    x = "h\udce9llo"  # surrogate escaped representation of C char*: "h\xe9llo"
    if li_std_wstring.non_utf8_c_str() != x:
        raise RuntimeError("surrogateescape not working")
    if li_std_wstring.size_wstring(x) != 5 and len(x) != 5:
        raise RuntimeError("Unexpected length")
