
import typedef_funcptr.*;

public class typedef_funcptr_runme {

  static {
    try {
	System.loadLibrary("typedef_funcptr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    int a = 100;
    int b = 10;

    if (typedef_funcptr.do_op(a,b,typedef_funcptr.addf) != 110)
      throw new RuntimeException("addf failed");
    if (typedef_funcptr.do_op(a,b,typedef_funcptr.subf) != 90)
      throw new RuntimeException("subf failed");

    if (typedef_funcptr.do_op_typedef_int(a,b,typedef_funcptr.addf) != 110)
      throw new RuntimeException("addf failed");
    if (typedef_funcptr.do_op_typedef_int(a,b,typedef_funcptr.subf) != 90)
      throw new RuntimeException("subf failed");

    if (typedef_funcptr.do_op_typedef_Integer(a,b,typedef_funcptr.addf) != 110)
      throw new RuntimeException("addf failed");
    if (typedef_funcptr.do_op_typedef_Integer(a,b,typedef_funcptr.subf) != 90)
      throw new RuntimeException("subf failed");
  }
}
