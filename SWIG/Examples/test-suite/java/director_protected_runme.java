
import director_protected.*;
import java.lang.reflect.*;

public class director_protected_runme {

  static {
    try {
      System.loadLibrary("director_protected");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {

    Bar b = new Bar();
    Foo f = b.create();
    FooBar fb = new FooBar();
    FooBar2 fb2 = new FooBar2();

    {
      String s = fb.used();
      if (!s.equals("Foo::pang();Bar::pong();Foo::pong();FooBar::ping();"))
        throw new RuntimeException( "bad FooBar::used" );
    }

    {
      String s = fb2.used();
      if (!s.equals("FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();"))
        throw new RuntimeException( "bad FooBar2::used" );
    }

    {
      String s = b.pong();
      if (!s.equals("Bar::pong();Foo::pong();Bar::ping();"))
        throw new RuntimeException( "bad Bar::pong" );
    }

    {
      String s = f.pong();
      if (!s.equals("Bar::pong();Foo::pong();Bar::ping();"))
        throw new RuntimeException(" bad Foo::pong" );
    }

    {
      String s3 = fb.pong();
      if (!s3.equals("Bar::pong();Foo::pong();FooBar::ping();"))
        throw new RuntimeException(" bad FooBar::pong" );
    }

    try {

      Method method = b.getClass().getDeclaredMethod("ping", (java.lang.Class[])null);
      if ( !Modifier.isProtected(method.getModifiers()) )
        throw new RuntimeException("Bar::ping should be protected" );

      method = f.getClass().getDeclaredMethod("ping", (java.lang.Class[])null);
      if ( !Modifier.isProtected(method.getModifiers()) )
        throw new RuntimeException("Foo::ping should be protected" );

    } catch (NoSuchMethodException n) {
      throw new RuntimeException("NoSuchmethodException caught. Test failed.");
    } catch (SecurityException s) {
      throw new RuntimeException("SecurityException caught. Test failed.");
    }
  }
}

class FooBar extends Bar {
  public String ping() {
    return "FooBar::ping();";
  }
}

class FooBar2 extends Bar {
  public String ping() {
    return "FooBar2::ping();";
  }
  public String pang() {
    return "FooBar2::pang();";
  }
}

