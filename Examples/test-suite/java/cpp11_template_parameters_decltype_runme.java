import cpp11_template_parameters_decltype.*;

public class cpp11_template_parameters_decltype_runme {

  static {
    try {
	System.loadLibrary("cpp11_template_parameters_decltype");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    boolean show = false; // for debugging

    cpp11_template_parameters_decltype.tester(show);
    Json json0 = new Json("hi");
    if (json0.getCtor() != 0)
      throw new RuntimeException("json0 failed");
    if (json0.mmm("bye") != 100)
      throw new RuntimeException("json0.mmm failed");

    Converter converter = new Converter();
    Json json1 = new Json(converter);
    if (json1.getCtor() != 1)
      throw new RuntimeException("json1 failed");
    if (json1.mmm(converter) != 101)
      throw new RuntimeException("json1.mmm failed");

    MapStringString myMapStringString = new MapStringString();
    Json json2 = new Json(myMapStringString);
    if (json2.getCtor() != 2)
      throw new RuntimeException("json2 failed");
    if (json2.mmm(myMapStringString) != 102)
      throw new RuntimeException("json2.mmm failed");

    VectorString myVectorString = new VectorString();
    Json json3 = new Json(myVectorString);
    if (json3.getCtor() != 3)
      throw new RuntimeException("json3 failed");
    if (json3.mmm(myVectorString) != 103)
      throw new RuntimeException("json3.mmm failed");
  }
}
