import cpp11_template_typedefs.*;

public class cpp11_template_typedefs_runme {

  static {
    try {
      System.loadLibrary("cpp11_template_typedefs");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    int alloc1 = cpp11_template_typedefs.get_bucket_allocator1();
    int alloc2 = cpp11_template_typedefs.get_bucket_allocator2();
  }
}

