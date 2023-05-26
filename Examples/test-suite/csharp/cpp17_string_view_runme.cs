using System;
using cpp17_string_viewNamespace;

public class runme
{
    static void Main()
    {
        // Checking expected use of %typemap(in) std::string_view {}
        cpp17_string_view.test_value("Fee");

        // Checking expected result of %typemap(out) std::string_view {}
        if (cpp17_string_view.test_value("Fi") != "Fi")
            throw new Exception("Test 1 failed");

        // Verify type-checking for %typemap(in) std::string_view {}
        try {
            cpp17_string_view.test_value(null);
            throw new Exception("Test 2 failed");
        } catch (ArgumentNullException) {
        }

        // Checking expected use of %typemap(in) const std::string_view & {}
        cpp17_string_view.test_const_reference("Fo");

        // Checking expected result of %typemap(out) const std::string_view& {}
        if (cpp17_string_view.test_const_reference("Fum") != "Fum")
            throw new Exception("Test 3 failed");

        // Verify type-checking for %typemap(in) const std::string_view & {}
        try {
            cpp17_string_view.test_const_reference(null);
            throw new Exception("Test 4 failed");
        } catch (ArgumentNullException) {
        }

        //
        // Input and output typemaps for pointers and non-const references to
        // std::string_view are *not* supported; the following tests confirm
        // that none of these cases are slipping through.
        //

        SWIGTYPE_p_std__string_view stringPtr = null;

        stringPtr = cpp17_string_view.test_pointer_out();

        cpp17_string_view.test_pointer(stringPtr);

        stringPtr = cpp17_string_view.test_const_pointer_out();

        cpp17_string_view.test_const_pointer(stringPtr);

        stringPtr = cpp17_string_view.test_reference_out();

        cpp17_string_view.test_reference(stringPtr);

        // Check throw exception specification
        try {
            cpp17_string_view.test_throw();
            throw new Exception("Test 5 failed");
        } catch (ApplicationException e) {
          if (e.Message != "test_throw message")
            throw new Exception("Test 5 string check: " + e.Message);
        }
        try {
            cpp17_string_view.test_const_reference_throw();
            throw new Exception("Test 6 failed");
        } catch (ApplicationException e) {
          if (e.Message != "test_const_reference_throw message")
            throw new Exception("Test 6 string check: " + e.Message);
        }

        // Global variables
        if (cpp17_string_view.ConstGlobalString != "const global string")
          throw new Exception("ConstGlobalString test");

        // Member variables
        Structure myStructure = new Structure();
        if (myStructure.ConstMemberString != "const member string")
          throw new Exception("ConstMemberString test");

        if (Structure.ConstStaticMemberString != "const static member string")
          throw new Exception("ConstStaticMemberString test");

        if (cpp17_string_view.stdstringview_empty() != "")
          throw new Exception("stdstringview_empty test");
        if (cpp17_string_view.c_empty() != "")
          throw new Exception("c_empty test");
        if (cpp17_string_view.c_null() != null)
          throw new Exception("c_null test");
        if (cpp17_string_view.get_null(cpp17_string_view.c_null()) != null)
          throw new Exception("get_null c_null test");
        if (cpp17_string_view.get_null(cpp17_string_view.c_empty()) != "non-null")
          throw new Exception("get_null c_empty test");
        if (cpp17_string_view.get_null(cpp17_string_view.stdstringview_empty()) != "non-null")
          throw new Exception("get_null stdstringview_empty test");
    }
}
