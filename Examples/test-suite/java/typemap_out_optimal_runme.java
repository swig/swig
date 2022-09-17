
import typemap_out_optimal.*;

public class typemap_out_optimal_runme {

  static {
    try {
	System.loadLibrary("typemap_out_optimal");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    XX.setTrace(false);
    {
      XX x = XX.create();
      x.delete();
    }
    {
      XX x = XX.createConst();
      x.delete();
    }
  }
}

