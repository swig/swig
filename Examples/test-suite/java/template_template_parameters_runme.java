

import template_template_parameters.*;

public class template_template_parameters_runme {

  static {
    try {
	System.loadLibrary("template_template_parameters");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // Test first part
    ListFastBool listBool = new ListFastBool();
    listBool.setItem(true);
    boolean x_boolean = listBool.getAllotype();
    if (listBool.getItem() != true)
      throw new RuntimeException("Failed");

    ListDefaultDouble listDouble = new ListDefaultDouble();
    listDouble.setItem(10.2);
    double x_double = listDouble.getAllotype();
    if (listDouble.getItem() != 10.2)
      throw new RuntimeException("Failed");

    // Test second part
    FloatTestStruct floatTestStruct = new FloatTestStruct();
    FloatContainer2 floatContainer2 = floatTestStruct.getX();
    floatContainer2.setX(8.1f);
    IntTestStruct intTestStruct = new IntTestStruct();
    IntContainer1 intContainer1 = intTestStruct.getX();
    intContainer1.setX(91);
    if (intContainer1.getX() != 91)
      throw new RuntimeException("Failed");
    if (intTestStruct.getX().getX() != 91)
      throw new RuntimeException("Failed");
    IntTestStruct intTestStructReturned = template_template_parameters.TestStructContainer1Method(intTestStruct);
    if (intTestStructReturned.getX().getX() != 101)
      throw new RuntimeException("Failed");
  }
}

