
import director_unroll.*;

public class director_unroll_runme {

  static {
    try {
      System.loadLibrary("director_unroll");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

      MyFoo a = new MyFoo();

      Bar b = new Bar();

      b.set(a);
      Foo c = b.get();

      if (!c.ping().equals("MyFoo::ping()"))
          throw new RuntimeException ( "c.ping()" );
  }
}

class MyFoo extends Foo {
    public String ping() {
        return "MyFoo::ping()";
    }
}

