
import director_abstract.*;

public class director_abstract_runme {

  static {
    try {
      System.loadLibrary("director_abstract");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

      MyFoo a = new MyFoo();

      if (!a.ping().equals("MyFoo::ping()")) {
          throw new RuntimeException ( "a.ping()" );
      }

      if (!a.pong().equals("Foo::pong();MyFoo::ping()")) {
          throw new RuntimeException ( "a.pong()" );
      }
  }
}

class MyFoo extends Foo {
    public String ping() {
        return "MyFoo::ping()";
    }
}

