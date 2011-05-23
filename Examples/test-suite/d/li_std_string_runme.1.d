module li_std_string_runme;

import tango.core.Exception;
import li_std_string.li_std_string;
import li_std_string.Structure;
import li_std_string.SWIGTYPE_p_std__string;


void main() {
  // Checking expected use of %typemap(in) std::string {}
  test_value("Fee");

  // Checking expected result of %typemap(out) std::string {}
  if (test_value("Fi") != "Fi")
      throw new Exception("Test 1 failed");

  // Verify type-checking for %typemap(in) std::string {}
  try {
      test_value(null);
      throw new Exception("Test 2 failed");
  } catch (IllegalArgumentException) {
  }

  // Checking expected use of %typemap(in) const std::string & {}
  test_const_reference("Fo");

  // Checking expected result of %typemap(out) const std::string& {}
  if (test_const_reference("Fum") != "Fum")
      throw new Exception("Test 3 failed");

  // Verify type-checking for %typemap(in) const std::string & {}
  try {
      test_const_reference(null);
      throw new Exception("Test 4 failed");
  } catch (IllegalArgumentException) {
  }

  // Input and output typemaps for pointers and non-const references to
  // std::string are *not* supported; the following tests confirm
  // that none of these cases are slipping through.

  SWIGTYPE_p_std__string stringPtr = null;

  stringPtr = test_pointer_out();
  test_pointer(stringPtr);

  stringPtr = test_const_pointer_out();
  test_const_pointer(stringPtr);

  stringPtr = test_reference_out();
  test_reference(stringPtr);

  // Check throw exception specification
  try {
      test_throw();
      throw new Exception("test 5 failed!");
  } catch (Exception e) {
    if (e.msg != "test_throw message")
      throw new Exception("Test 5 string check: " ~ e.msg);
  }
  try {
      test_const_reference_throw();
      throw new Exception("test 6 failed!");
  } catch (Exception e) {
    if (e.msg != "test_const_reference_throw message")
      throw new Exception("Test 6 string check: " ~ e.msg);
  }

  // Global variables.
  const char[] s = "initial string";
  if (GlobalString2 != "global string 2")
    throw new Exception("GlobalString2 test 1");
  GlobalString2 = s;
  if (GlobalString2 != s)
    throw new Exception("GlobalString2 test 2");
  if (ConstGlobalString != "const global string")
    throw new Exception("ConstGlobalString test");

  // Member variables.
  auto myStructure = new Structure();
  if (myStructure.MemberString2 != "member string 2")
    throw new Exception("MemberString2 test 1");
  myStructure.MemberString2 = s;
  if (myStructure.MemberString2 != s)
    throw new Exception("MemberString2 test 2");
  if (myStructure.ConstMemberString != "const member string")
    throw new Exception("ConstMemberString test");

  // Static member variables.
  if (Structure.StaticMemberString2 != "static member string 2")
    throw new Exception("StaticMemberString2 test 1");
  Structure.StaticMemberString2 = s;
  if (Structure.StaticMemberString2 != s)
    throw new Exception("StaticMemberString2 test 2");
  if (Structure.ConstStaticMemberString != "const static member string")
    throw new Exception("ConstStaticMemberString test");
}
