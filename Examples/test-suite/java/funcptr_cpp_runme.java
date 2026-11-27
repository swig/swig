
import funcptr_cpp.*;

public class funcptr_cpp_runme {

  static {
    try {
      System.loadLibrary("funcptr_cpp");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    // The in typemaps with locals supply the function pointer
    if (funcptr_cpp.callLocalsNamed(1) != 2)
      throw new RuntimeException("callLocalsNamed failed");
    if (funcptr_cpp.callLocalsUnnamed(2, 3) != 5)
      throw new RuntimeException("callLocalsUnnamed failed");
  }
}
