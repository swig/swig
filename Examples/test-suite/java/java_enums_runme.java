
import java_enums.*;

public class java_enums_runme {
  static {
    try {
        System.loadLibrary("java_enums");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) 
  {
      int number = 200;

      // Switch statement will only compile if these enums are initialised 
      // from a constant Java value, that is not from a function call
      switch(number) {
          case java_enums.FIDDLE:
              break;
          case java_enums.STICKS:
              break;
          case java_enums.BONGO:
              break;
          case java_enums.DRUMS:
              break;
          default:
              break;
      }
      if (java_enums.DRUMS != 15)
          throw new RuntimeException("Incorrect value for DRUMS");

      // check typemaps use short for this enum
      short nonsense = java_enums.POPPYCOCK;
      short tst1 = java_enums.test1(nonsense);
      short tst2 = java_enums.test2(nonsense);
  }
}
