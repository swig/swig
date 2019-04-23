
import director_exception_catches.*;

public class director_exception_catches_runme {

  static {
    try {
      System.loadLibrary("director_exception_catches");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    BaseClass b = new director_exception_catches_MyClass();

    try {
      String s = BaseClass.call_description(b);
      throw new RuntimeException("Failed to catch exception");
    } catch (NullPointerException e) {
      if (!e.getMessage().startsWith("Testing exception thrown in BaseClass.description"))
        throw new RuntimeException("Unexpected exception message: " + e.getMessage());
    }
  }
}

class director_exception_catches_MyClass extends BaseClass {
  @Override
  public String description() {
    throw new NullPointerException("Testing exception thrown in BaseClass.description");
  }
}

