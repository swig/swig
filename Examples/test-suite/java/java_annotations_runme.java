import java_annotations.*;

public class java_annotations_runme {
  static {
    try {
        System.loadLibrary("java_annotations");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

  }
}