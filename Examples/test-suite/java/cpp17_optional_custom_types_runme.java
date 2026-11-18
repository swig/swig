
// This is the ret_by_value runtime testcase. It checks that SWIG handles
// return by value okay.

import cpp17_optional_custom_types.*;

public class cpp17_optional_custom_types_runme {

  static {
    try {
	System.loadLibrary("cpp17_optional_custom_types");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void testGettingPointByValue(TestObject obj, Point expectedPoint) {
    if (!obj.getPoint().isEqual(expectedPoint)) {
      System.err.println("Runtime get by value test failed. getPoint=" + obj.getPoint().toString() + " instead of " + expectedPoint.toString());
      System.exit(1);
    }
  }


  public static void testGettingPointOptional(TestObject obj, Point expectedPoint) {
    if (!(obj.getPointOpt() != null && obj.getPointOpt().isEqual(expectedPoint))) {
      System.err.println("Runtime get optional test failed. getPointOpt=" + obj.getPointOpt() + " instead of " + expectedPoint);
      System.exit(1);
    }
  }

  public static void testGettingCircleOptional(TestObject obj, Circle expectedCircle, Point expectedPoint, int expectedRadius, String expectedName) {

    if (!(obj.getCircleOpt() != null && obj.getCircleOpt().isEqual(expectedCircle))) {
      System.err.println("Runtime get optional test failed. getCircleOpt=" + obj.getCircleOpt() + " instead of " + expectedCircle);
      System.exit(1);
    }

    if (obj.getCircleOpt() != null) {
      Circle c = obj.getCircleOpt();
      if (!(c.getCenter() != null && c.getCenter().isEqual(expectedPoint))) {
        System.err.println("Runtime get optional test failed. getCenter=" + c.getCenter() + " instead of " + expectedPoint);
        System.exit(1);
      }
      if (!(c.getRadius() != null && c.getRadius() == expectedRadius)) {
        System.err.println("Runtime get optional test failed. getRadius=" + c.getRadius() + " instead of " + expectedRadius);
        System.exit(1);
      }
      if (!(c.getName() != null && c.getName().equals(expectedName))) {
        System.err.println("Runtime get optional test failed. getName=" + c.getName() + " instead of " + expectedName);
        System.exit(1);
      }
    }
  }


  public static void main(String argv[]) {

    int expectedRadius = 15;
    String expectedName = "rounded";
    Point expectedPoint = new Point(10,10);
    Circle expectedCircle = new Circle(expectedPoint, expectedRadius, expectedName);

    TestObject obj = new TestObject(expectedPoint, expectedCircle);

    // Getters by value
    testGettingPointByValue(obj, expectedPoint);
    Point expectedPoint2 = new Point(12,12);
    // Setting value
    obj.setPoint(expectedPoint2);
    testGettingPointByValue(obj, expectedPoint2);

    // Getters with optional
    testGettingPointOptional(obj, expectedPoint);

    // Setting null to optional
    obj.setPointOpt(null);
    if (obj.getPointOpt() != null) {
      System.err.println("Runtime set null test failed. getPointOpt=" + obj.getPointOpt() + " instead of " + null);
      System.exit(1);
    }

    // Setting value to optional
    obj.setPointOpt(expectedPoint);    
    testGettingPointOptional(obj, expectedPoint);

    // Testing of struct held by optional
    // Getters with optional
    testGettingCircleOptional(obj, expectedCircle, expectedPoint, expectedRadius, expectedName);

    // Setting null to optional
    obj.setCircleOpt(null);
    if (obj.getCircleOpt() != null) {
      System.err.println("Runtime set null test failed. getCircleOpt=" + obj.getCircleOpt() + " instead of " + null);
      System.exit(1);
    }

    // Setting value to optional
    obj.setCircleOpt(expectedCircle);    

    testGettingCircleOptional(obj, expectedCircle, expectedPoint, expectedRadius, expectedName);

    obj.delete();
  }
}

