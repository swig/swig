
// This is the ret_by_value runtime testcase. It checks that SWIG handles
// return by value okay.

import cpp17_optional_std_types.*;

public class cpp17_optional_std_types_runme {

  static {
    try {
	System.loadLibrary("cpp17_optional_std_types");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void testGettingStringByValue(TestObject obj, String expectedString) {
    if (!obj.getName().equals(expectedString)) {
      System.err.println("Runtime get by value test failed. getName=" + obj.getName() + " instead of " + expectedString);
      System.exit(1);
    }
  }


  public static void testGettingStringOptional(TestObject obj, String expectedString) {
    if (!(obj.getNameOpt() != null && obj.getNameOpt().equals(expectedString))) {
      System.err.println("Runtime get optional test failed. getNameOpt=" + obj.getNameOpt() + " instead of " + expectedString);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    String expectedString = "tomato";

    TestObject obj = new TestObject(expectedString);

    // Getters by value
    testGettingStringByValue(obj, expectedString);
    
    String expectedString2 = expectedString + expectedString;
    // Setting value
    obj.setName(expectedString2);
    testGettingStringByValue(obj, expectedString2);

    // Getters with optional
    testGettingStringOptional(obj, expectedString);

    // Setting null to optional
    obj.setNameOpt(null);
    if (obj.getNameOpt() != null) {
      System.err.println("Runtime set null test failed. getNameOpt=" + obj.getNameOpt() + " instead of " + null);
      System.exit(1);
    }

    // Setting value to optional
    obj.setNameOpt(expectedString);
    testGettingStringOptional(obj, expectedString);

    obj.delete();
  }
}

