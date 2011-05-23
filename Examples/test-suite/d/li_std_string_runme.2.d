module li_std_string_runme;

import std.exception;
import li_std_string.li_std_string;
import li_std_string.Structure;
import li_std_string.SWIGTYPE_p_std__string;

void main() {
  // Checking expected use of %typemap(in) std::string {}
  test_value("Fee");

  // Checking expected result of %typemap(out) std::string {}
  enforce(test_value("Fi") == "Fi", "Test 1 failed");

  // Verify type-checking for %typemap(in) std::string {}
  enforceThrows( (){ test_value(null); }, "Test 2 failed.");

  // Checking expected use of %typemap(in) const std::string & {}
  test_const_reference("Fo");

  // Checking expected result of %typemap(out) const std::string& {}
  enforce(test_const_reference("Fum") == "Fum", "Test 3 failed");

  // Verify type-checking for %typemap(in) const std::string & {}
  enforceThrows( (){ test_const_reference(null); }, "Test 4 failed.");

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
    enforce(e.msg == "test_throw message", "Test 5 string check: " ~ e.msg);
  }
  try {
    test_const_reference_throw();
    throw new Exception("test 6 failed!");
  } catch (Exception e) {
    enforce(e.msg == "test_const_reference_throw message", "Test 6 string check: " ~ e.msg);
  }

  // Global variables.
  const string s = "initial string";
  enforce(GlobalString2 == "global string 2", "GlobalString2 test 1");
  GlobalString2 = s;
  enforce(GlobalString2 == s, "GlobalString2 test 2");
  enforce(ConstGlobalString == "const global string", "ConstGlobalString test");

  // Member variables.
  auto myStructure = new Structure();
  enforce(myStructure.MemberString2 == "member string 2", "MemberString2 test 1");
  myStructure.MemberString2 = s;
  enforce(myStructure.MemberString2 == s, "MemberString2 test 2");
  enforce(myStructure.ConstMemberString == "const member string", "ConstMemberString test");

  // Static member variables.
  enforce(Structure.StaticMemberString2 == "static member string 2", "StaticMemberString2 test 1");
  Structure.StaticMemberString2 = s;
  enforce(Structure.StaticMemberString2 == s, "StaticMemberString2 test 2");
  enforce(Structure.ConstStaticMemberString == "const static member string", "ConstStaticMemberString test");
}

private void enforceThrows(void delegate() dg, string errorMessage) {
  bool hasThrown;
  try {
    dg();
  } catch (Exception) {
    hasThrown = true;
  } finally {
    enforce(hasThrown, errorMessage);
  }
}
