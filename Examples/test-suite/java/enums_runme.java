
import enums.*;

public class enums_runme {

  static {
    try {
        System.loadLibrary("enums");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[])
  {
    // Values written into the Java code by %javaconst(1)
    if (WideCharEnum.WideCharW.swigValue() != 'w') throw new RuntimeException("WideCharW failed");
    if (WideCharEnum.WideCharE.swigValue() != 0xE9) throw new RuntimeException("WideCharE failed");
    if (WideCharEnum.WideCharSmile.swigValue() != 0x263A) throw new RuntimeException("WideCharSmile failed");
  }
}
