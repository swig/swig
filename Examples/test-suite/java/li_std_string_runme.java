import lib_std_string.*;

public class lib_std_string_runme {

  static {
    try {
        System.loadLibrary("lib_std_string");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) throws Throwable
  {
      // Checking expected use of %typemap(in) std::string {}
      lib_std_string.test_value("Fee");

      // Checking expected result of %typemap(out) std::string {}
      if (!lib_std_string.test_value("Fi").equals("Fi"))
          throw new RuntimeException("Test 1 failed");

      // Verify type-checking for %typemap(in) std::string {}
      try {
          lib_std_string.test_value(null);
          throw new RuntimeException("Test 2 failed");
      } catch (NullPointerException e) {
      }

      // Checking expected use of %typemap(in) const std::string & {}
      lib_std_string.test_const_reference("Fo");

      // Checking expected result of %typemap(out) const std::string& {}
      if (!lib_std_string.test_const_reference("Fum").equals("Fum"))
          throw new RuntimeException("Test 3 failed");

      // Verify type-checking for %typemap(in) const std::string & {}
      try {
          lib_std_string.test_const_reference(null);
          throw new RuntimeException("Test 4 failed");
      } catch (NullPointerException e) {
      }

      //
      // Input and output typemaps for pointers and non-const references to
      // std::string are *not* supported; the following tests confirm
      // that none of these cases are slipping through.
      //

      SWIGTYPE_p_std__string stringPtr = null;

      stringPtr = lib_std_string.test_pointer_out();

      lib_std_string.test_pointer(stringPtr);

      stringPtr = lib_std_string.test_const_pointer_out();

      lib_std_string.test_const_pointer(stringPtr);

      stringPtr = lib_std_string.test_reference_out();

      lib_std_string.test_reference(stringPtr);

      // Check throw exception specification
      try {
          lib_std_string.test_throw();
          throw new Throwable("Test 5 failed");
      } catch (RuntimeException e) {
      }
      try {
          lib_std_string.test_const_reference_throw();
          throw new Throwable("Test 6 failed");
      } catch (RuntimeException e) {
      }
  }
}
