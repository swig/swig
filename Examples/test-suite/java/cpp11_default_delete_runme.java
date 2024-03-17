import cpp11_default_delete.*;

public class cpp11_default_delete_runme {

  static {
    try {
	System.loadLibrary("cpp11_default_delete");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    sometype st = new sometype(22.2);
    sometype.take(st);
    st = sometype.make(33.3);

    sometype2 st2 = new sometype2(22.2);
    sometype2.take(st2);
    st2 = sometype2.make(33.3);

    sometype3 st3 = sometype3.make(22);
    sometype3.take(st3);
    st3 = sometype3.make(33);
  }
}

