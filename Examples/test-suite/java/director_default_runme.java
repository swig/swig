
import director_default.*;

public class director_default_runme {

  static {
    try {
      System.loadLibrary("director_default");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    {
      MyFoo a = new MyFoo();
      a = new MyFoo(10);
    }

    MyFoo a = new MyFoo();
    if (!a.GetMsg().equals("MyFoo-default")) {
      throw new RuntimeException ( "Test 1 failed" );
    }
    if (!a.GetMsg("boo").equals("MyFoo-boo")) {
      throw new RuntimeException ( "Test 2 failed" );
    }

    Foo b = new Foo();
    if (!b.GetMsg().equals("Foo-default")) {
      throw new RuntimeException ( "Test 1 failed" );
    }
    if (!b.GetMsg("boo").equals("Foo-boo")) {
      throw new RuntimeException ( "Test 2 failed" );
    }

  }
}

class MyFoo extends Foo {
    public MyFoo() {
      super();
    }
    public MyFoo(int i) {
      super(i);
    }
    public String Msg(String msg) { 
      return "MyFoo-" + msg; 
    }
}

