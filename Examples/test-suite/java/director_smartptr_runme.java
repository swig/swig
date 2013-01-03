// Make sure that directors are connected and disconnected when used inconjunction with
// being a smart pointer

public class director_smartptr_runme {

  static {
    try {
      System.loadLibrary("director_smartptr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  public static void main(String argv[]) {
    director_smartptr_MyBarFoo myBarFoo =
      new director_smartptr_MyBarFoo();
  }

}

class director_smartptr_MyBarFoo extends director_smartptr.Foo {

  @Override
  public String ping() {
    return "director_smartptr_MyBarFoo.ping();";
  }

  @Override
  public String pong() {
    return "director_smartptr_MyBarFoo.pong();" + ping();
  }

  @Override
  public String fooBar(director_smartptr.FooBar fooBar) {
    return fooBar.FooBarDo();
  }

  @Override
  public director_smartptr.Foo makeFoo() {
    return new director_smartptr.Foo();
  }

  @Override
  public director_smartptr.FooBar makeFooBar() {
    return new director_smartptr.FooBar();
  }
}