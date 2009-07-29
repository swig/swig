
import special_variable_functions.*;

public class special_variable_functions_runme {

  static {
    try {
	System.loadLibrary("special_variable_functions");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    Name name = new Name();
    if (!special_variable_functions.testFred(name).equals("none"))
      throw new RuntimeException("test failed");
    if (!special_variable_functions.testJack(name).equals("$specialname"))
      throw new RuntimeException("test failed");
    if (!special_variable_functions.testJill(name).equals("jilly"))
      throw new RuntimeException("test failed");
    if (!special_variable_functions.testMary(name).equals("SWIGTYPE_p_NameWrap"))
      throw new RuntimeException("test failed");
    NewName newName = NewName.factory("factoryname");
    name = newName.getStoredName();
  }
}
