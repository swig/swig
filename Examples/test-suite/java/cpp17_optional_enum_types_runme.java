
// This is the ret_by_value runtime testcase. It checks that SWIG handles
// return by value okay.

import cpp17_optional_enum_types.*;

public class cpp17_optional_enum_types_runme {

  static {
    try {
	System.loadLibrary("cpp17_optional_enum_types");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void testGettingEnumByValue(TestObject obj, NonOptionalEnumTest expectedNonOptionalEnum) {
    if (!obj.getNonOptionalEnum().equals(expectedNonOptionalEnum)) {
      System.err.println("Runtime get by value test failed. getNonOptionalEnum=" + obj.getNonOptionalEnum() + " instead of " + expectedNonOptionalEnum);
      System.exit(1);
    }
  }

  public static void testGettingEnumOptional(TestObject obj, OptionalEnumTest expectedOptionalEnum) {
    if (!(obj.getOptionalEnum() != null && obj.getOptionalEnum().equals(expectedOptionalEnum))) {
      System.err.println("Runtime get optional test failed. getOptionalEnum=" + obj.getOptionalEnum() + " instead of " + expectedOptionalEnum);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    OptionalEnumTest expectedOptionalEnum = OptionalEnumTest.B;
    NonOptionalEnumTest expectedNonOptionalEnum = NonOptionalEnumTest.E;

    TestObject obj = new TestObject(expectedOptionalEnum, expectedNonOptionalEnum);

    // Getters by value
    testGettingEnumByValue(obj, expectedNonOptionalEnum);
    
    NonOptionalEnumTest expectedNonOptionalEnum2 = NonOptionalEnumTest.F;
    // Setting value
    obj.setNonOptionalEnum(expectedNonOptionalEnum2);
    testGettingEnumByValue(obj, expectedNonOptionalEnum2);

    // Getters with optional
    testGettingEnumOptional(obj, expectedOptionalEnum);

    // Setting null to optional
    obj.setOptionalEnum(null);
    if (obj.getOptionalEnum() != null) {
      System.err.println("Runtime set null test failed. getOptionalEnum=" + obj.getOptionalEnum() + " instead of " + null);
      System.exit(1);
    }

    // Setting value to optional
    obj.setOptionalEnum(expectedOptionalEnum);
    testGettingEnumOptional(obj, expectedOptionalEnum);

    obj.delete();
  }
}

