
// This is the ret_by_value runtime testcase. It checks that SWIG handles
// return by value okay.

import cpp11_optional_primitive_types.*;

public class cpp11_optional_primitive_types_runme {

  static {
    try {
	System.loadLibrary("cpp11_optional_primitive_types");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void testGettingTypesByValue(TestObject obj, boolean expectedBool, int expectedInt, float expectedFloat, double expectedDouble) {
    if (obj.getBool() != expectedBool) {
      System.err.println("Runtime get by value test failed. getBool=" + obj.getBool() + " instead of " + expectedBool);
      System.exit(1);
    }
    if (obj.getInt() != expectedInt) {
      System.err.println("Runtime get by value test failed. getInt=" + obj.getInt() + " instead of " + expectedInt);
      System.exit(1);
    }
    if (obj.getFloat() != expectedFloat) {
      System.err.println("Runtime get by value test failed. getFloat=" + obj.getFloat() + " instead of " + expectedFloat);
      System.exit(1);
    }
    if (obj.getDouble() != expectedDouble) {
      System.err.println("Runtime get by value test failed. getDouble=" + obj.getDouble() + " instead of " + expectedDouble);
      System.exit(1);
    }
  }

  public static void testGettingTypesOptional(TestObject obj, boolean expectedBool, int expectedInt, float expectedFloat, double expectedDouble) {
    if (!(obj.getBoolOpt() != null && obj.getBoolOpt() == expectedBool)) {
      System.err.println("Runtime get optional test failed. getBoolOpt=" + obj.getBoolOpt() + " instead of " + expectedBool);
      System.exit(1);
    }
    if (!(obj.getIntOpt() != null && obj.getIntOpt() == expectedInt)) {
      System.err.println("Runtime get optional test failed. getIntOpt=" + obj.getIntOpt() + " instead of " + expectedInt);
      System.exit(1);
    }
    if (!(obj.getFloatOpt() != null && obj.getFloatOpt() == expectedFloat)) {
      System.err.println("Runtime get optional test failed. getFloatOpt=" + obj.getFloatOpt() + " instead of " + expectedFloat);
      System.exit(1);
    }
    if (!(obj.getDoubleOpt() != null && obj.getDoubleOpt() == expectedDouble)) {
      System.err.println("Runtime get optional test failed. getDoubleOpt=" + obj.getDoubleOpt() + " instead of " + expectedDouble);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    boolean expectedBool = false;
    int expectedInt = 10;
    float expectedFloat = 11.f;
    double expectedDouble = 13.0;

    TestObject obj = new TestObject(expectedBool, expectedInt, expectedFloat, expectedDouble);

    // Getters by value
    testGettingTypesByValue(obj, expectedBool, expectedInt, expectedFloat, expectedDouble);

    // Setting value
    boolean expectedBool2 = true;
    int expectedInt2 = expectedInt + expectedInt;
    float expectedFloat2 = expectedFloat + expectedFloat;
    double expectedDouble2 = expectedDouble + expectedDouble;
    obj.setBool(expectedBool2);
    obj.setInt(expectedInt2);
    obj.setFloat(expectedFloat2);
    obj.setDouble(expectedDouble2);
    testGettingTypesByValue(obj, expectedBool2, expectedInt2, expectedFloat2, expectedDouble2);

    // Getters with optional
    testGettingTypesOptional(obj, expectedBool, expectedInt, expectedFloat, expectedDouble);

    if (obj.getNullopt() != null) {
      System.err.println("Runtime get optional test failed. getNullopt=" + obj.getNullopt() + " instead of " + null);
      System.exit(1);
    }

    // Setting null to optional
    obj.setBoolOpt(null);
    obj.setIntOpt(null);
    obj.setFloatOpt(null);
    obj.setDoubleOpt(null);
    if (obj.getBoolOpt() != null) {
      System.err.println("Runtime set null test failed. getBoolOpt=" + obj.getBoolOpt() + " instead of " + null);
      System.exit(1);
    }
    if (obj.getIntOpt() != null) {
      System.err.println("Runtime set null test failed. getIntOpt=" + obj.getIntOpt() + " instead of " + null);
      System.exit(1);
    }
    if (obj.getFloatOpt() != null) {
      System.err.println("Runtime set null test failed. getFloatOpt=" + obj.getFloatOpt() + " instead of " + null);
      System.exit(1);
    }
    if (obj.getDoubleOpt() != null) {
      System.err.println("Runtime set null test failed. getDoubleOpt=" + obj.getDoubleOpt() + " instead of " + null);
      System.exit(1);
    }

    // Setting value to optional
    obj.setBoolOpt(expectedBool);
    obj.setIntOpt(expectedInt);
    obj.setFloatOpt(expectedFloat);
    obj.setDoubleOpt(expectedDouble);
    testGettingTypesOptional(obj, expectedBool, expectedInt, expectedFloat, expectedDouble);

    // Testing optional with nullopt
    if (obj.getNullopt() != null) {
      System.err.println("Runtime set value to optional test failed. getNullopt=" + obj.getNullopt() + " instead of " + null);
      System.exit(1);
    }

    obj.delete();
  }
}

