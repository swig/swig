import sys
from li_std_string import *

def check(condition):
    if not condition:
        raise RuntimeError

# Bad Unicode input check
# This check is run first to check that %error_clear is called the first time SWIG_AsPtr_std_string()
# is called setting the descriptor singleton (by calling SWIG_TypeQuery()).
# Bug https://github.com/swig/swig/issues/3051.
exceptionRaised = False
try:
    if sys.version_info[0:2] < (3, 0):
        v = u"./\uDCFC.conf"
    else:
        v = "./\uDCFC.conf"
    test_value(v)
except TypeError:
    exceptionRaised = True
check(exceptionRaised)

# Checking expected use of %typemap(in) std::string {}
test_value("Fee")

# Checking expected result of %typemap(out) std::string {}
check(test_value("Fi") == "Fi")

# Verify type-checking for %typemap(in) std::string {}
exceptionRaised = False
try:
    test_value(0)
except TypeError:
    exceptionRaised = True
check(exceptionRaised)

# Checking expected use of %typemap(in) const std::string & {}
test_const_reference("Fo")

# Checking expected result of %typemap(out) const std::string& {}
check(test_const_reference("Fum") == "Fum")

# Verify type-checking for %typemap(in) const std::string & {}
exceptionRaised = False
try:
    test_const_reference(0)
except TypeError:
    exceptionRaised = True
check(exceptionRaised)

#
# Input and output typemaps for pointers and non-const references to
# std::string are *not* supported; the following tests confirm
# that none of these cases are slipping through.
#

exceptionRaised = False
try:
    test_pointer("foo")
except TypeError:
    exceptionRaised = True
check(exceptionRaised)

result = test_pointer_out()
check(not isinstance(result, str))

exceptionRaised = False
try:
    test_const_pointer("bar")
except TypeError:
    exceptionRaised = True
check(exceptionRaised)

result = test_const_pointer_out()
check(not isinstance(result, str))

exceptionRaised = False
try:
    test_reference("foo")
except TypeError:
    exceptionRaised = True
check(exceptionRaised)

result = test_reference_out()
check(not isinstance(result, str))


# Member Strings
myStructure = Structure()
if myStructure.MemberString2 != "member string 2":
    raise RuntimeError
s = "Hello"
myStructure.MemberString2 = s
if myStructure.MemberString2 != s:
    raise RuntimeError
if myStructure.ConstMemberString != "const member string":
    raise RuntimeError 


if cvar.Structure_StaticMemberString2 != "static member string 2":
    raise RuntimeError
cvar.Structure_StaticMemberString2 = s
if cvar.Structure_StaticMemberString2 != s:
    raise RuntimeError
if Structure.ConstStaticMemberString != "const static member string":
    raise RuntimeError


if test_reference_input("hello") != "hello":
    raise RuntimeError
s = test_reference_inout("hello")
if s != "hellohello":
    raise RuntimeError
if test_reference_output() != "output":
    raise RuntimeError


if stdstring_empty() != "":
    raise RuntimeError

if c_empty() != "":
    raise RuntimeError


if c_null() != None:
    raise RuntimeError


if get_null(c_null()) != None:
    raise RuntimeError


if get_null(c_empty()) != "non-null":
    raise RuntimeError

if get_null(stdstring_empty()) != "non-null":
    raise RuntimeError
