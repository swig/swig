

import template_default_class_parms.*;

public class template_default_class_parms_runme {

  static {
    try {
	System.loadLibrary("template_default_class_parms");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    {
      DefaultBar bar = new DefaultBar(20.0, new SomeType(), 10);
      double d = bar.getCType();
      SomeType s = bar.getDType();
      int i = bar.getEType();
      d = bar.method(d, s, i);
    }
    {
      DefaultFoo foo = new DefaultFoo(new SomeType());
      SomeType s = foo.getTType();
      s = foo.method(s);
    }
    {
      BarAnotherTypeBool bar = new BarAnotherTypeBool(new AnotherType(), true, 10);
      AnotherType a = bar.getCType();
      boolean b = bar.getDType();
      int i = bar.getEType();
      a = bar.method(a, b, i);
    }
    {
      FooAnotherType foo = new FooAnotherType(new AnotherType());
      AnotherType a = foo.getTType();
      a = foo.method(a);
    }
  }
}

