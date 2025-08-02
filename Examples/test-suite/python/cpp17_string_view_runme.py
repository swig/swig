import cpp17_string_view

import sys
if sys.version_info[0:1] < (3, 0):
    # string_view.i only supported for Python3
    sys.exit(0)

# Checking expected use of %typemap(in) std::string_view {}
cpp17_string_view.test_value("Fee")

# Checking expected result of %typemap(out) std::string_view {}
if cpp17_string_view.test_value("Fi") != "Fi":
    raise RuntimeError("Test 1: "+cpp17_string_view.test_value("Fi"))

# Checking expected use of %typemap(in) const std::string_view & {}
cpp17_string_view.test_const_reference("Fo")

# Checking expected result of %typemap(out) const std.string_view& {}
if cpp17_string_view.test_const_reference("Fum") != "Fum":
    raise RuntimeError("Test 3")

# Input and output typemaps for pointers and non-const references to
# std::string_view are *not* supported; the following tests confirm
# that none of these cases are slipping through.

stringPtr = cpp17_string_view.test_pointer_out()

cpp17_string_view.test_pointer(stringPtr)

stringPtr = cpp17_string_view.test_const_pointer_out()

cpp17_string_view.test_const_pointer(stringPtr)

stringPtr = cpp17_string_view.test_reference_out()

cpp17_string_view.test_reference(stringPtr)

cpp17_string_view.test_multiple("fee", "fi", "fo", "fum")

# Global variables
s = "initial string"
if cpp17_string_view.ConstGlobalString != "const global string":
    raise RuntimeError("ConstGlobalString test")

# Member variables
myStructure = cpp17_string_view.Structure()
if myStructure.ConstMemberString != "const member string":
    raise RuntimeError("ConstMemberString test")

if cpp17_string_view.Structure.ConstStaticMemberString != "const static member string":
    raise RuntimeError("ConstStaticMemberString test")

cpp17_string_view.test_const_reference_returning_void("foo")
