using System;
using li_std_stringNamespace;

public class runme
{
    static void Main() 
    {
        // Checking expected use of %typemap(in) std::string {}
        li_std_string.test_value("Fee");

        // Checking expected result of %typemap(out) std::string {}
        if (li_std_string.test_value("Fi") != "Fi")
            throw new Exception("Test 1 failed");

        // Verify type-checking for %typemap(in) std::string {}
        try {
            li_std_string.test_value(null);
            throw new Exception("Test 2 failed");
        } catch (ArgumentNullException) {
        }

        // Checking expected use of %typemap(in) const std::string & {}
        li_std_string.test_const_reference("Fo");

        // Checking expected result of %typemap(out) const std::string& {}
        if (li_std_string.test_const_reference("Fum") != "Fum")
            throw new Exception("Test 3 failed");

        // Verify type-checking for %typemap(in) const std::string & {}
        try {
            li_std_string.test_const_reference(null);
            throw new Exception("Test 4 failed");
        } catch (ArgumentNullException) {
        }

        //
        // Input and output typemaps for pointers and non-const references to
        // std::string are *not* supported; the following tests confirm
        // that none of these cases are slipping through.
        //
        
        SWIGTYPE_p_std__string stringPtr = null;
        
        stringPtr = li_std_string.test_pointer_out();

        li_std_string.test_pointer(stringPtr);

        stringPtr = li_std_string.test_const_pointer_out();

        li_std_string.test_const_pointer(stringPtr);

        stringPtr = li_std_string.test_reference_out();

        li_std_string.test_reference(stringPtr);

    }
}
