
import director_basic.*;

public class director_basic_runme {

  static {
    try {
      System.loadLibrary("director_basic");
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

      Foo b = new Foo();

      if (!b.ping().equals("Foo::ping()")) {
          throw new RuntimeException ( "b.ping()" );
      }

      if (!b.pong().equals("Foo::pong();Foo::ping()")) {
          throw new RuntimeException ( "b.pong()" );
      }

      A1 a1 = new A1(1, false);
      a1.delete();
  }
}

class MyFoo extends Foo {
    public String ping() {
        return "MyFoo::ping()";
    }
}

