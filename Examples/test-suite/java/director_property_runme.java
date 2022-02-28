
import director_property.*;

public class director_property_runme {

  static {
    try {
      System.loadLibrary("director_property");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    {
      Foo a = new director_property_MyFoo();
      if (!a.getA().equals("")) {
        throw new RuntimeException( "Test failed" );
      }
      a.setA("Hello");
      if (!a.getA().equals("Hello set from MyFoo")) {
        throw new RuntimeException( "Test failed" );
      }
      a.setAByRef("Hello");
      if (!a.getA().equals("Hello setAByRef from MyFoo")) {
        throw new RuntimeException( "Test failed" );
      }
      a.delete();
    }

    {
      Foo a_original = new director_property_MyFoo();
      Foo a = Foo.get_self(a_original);
      if (!a.getA().equals("")) {
        throw new RuntimeException( "Test failed" );
      }
      a.setA("Hello");
      if (!a.getA().equals("Hello set from MyFoo")) {
        throw new RuntimeException( "Test failed" );
      }
      a.setAByRef("Hello");
      if (!a.getA().equals("Hello setAByRef from MyFoo")) {
        throw new RuntimeException( "Test failed" );
      }
      a.delete();
    }
  }
}

class director_property_MyFoo extends Foo {
    public director_property_MyFoo() {
      super();
    }
    @Override
    public void setA(String a) {
      super.setA(a + " set from MyFoo");
    }
    @Override
    public void setAByRef(String a) {
      super.setA(a + " setAByRef from MyFoo");
    }
}


