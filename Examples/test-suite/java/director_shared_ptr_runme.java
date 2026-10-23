// Make sure that directors are connected and disconnected when used inconjunction with
// being a smart pointer

public class director_shared_ptr_runme {

  static {
    try {
      System.loadLibrary("director_shared_ptr");
    } catch (UnsatisfiedLinkError e) {
      System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e);
      System.exit(1);
    }
  }

  private static void check(String got, String expected) {
    if (!got.equals(expected))
      throw new RuntimeException("Failed, got: " + got + " expected: " + expected);
  }

  public static void main(String argv[]) {
    director_shared_ptr.FooBar fooBar = new director_shared_ptr.FooBar();

    director_shared_ptr.Foo myBarFoo = new director_shared_ptr_MyBarFoo();
    check(myBarFoo.ping(), "director_shared_ptr_MyBarFoo.ping()");
    check(director_shared_ptr.Foo.callPong(myBarFoo), "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()");
    check(director_shared_ptr.Foo.callUpcall(myBarFoo, fooBar), "override;Bar::Foo2::Foo2Bar()");

    director_shared_ptr.Foo myFoo = myBarFoo.makeFoo();
    check(myFoo.pong(), "Foo::pong();Foo::ping()");
    check(director_shared_ptr.Foo.callPong(myFoo), "Foo::pong();Foo::ping()");
    check(myFoo.upcall(fooBar), "Bar::Foo2::Foo2Bar()");

    director_shared_ptr.Foo myFoo2 = new director_shared_ptr.Foo().makeFoo();
    check(myFoo2.pong(), "Foo::pong();Foo::ping()");
    check(director_shared_ptr.Foo.callPong(myFoo2), "Foo::pong();Foo::ping()");

    director_shared_ptr.FooDerived myBarFooDerived = new director_shared_ptr_MyBarFooDerived();
    check(myBarFooDerived.ping(), "director_shared_ptr_MyBarFooDerived.ping()");
    check(director_shared_ptr.FooDerived.callPong(myBarFooDerived), "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()");
    check(director_shared_ptr.FooDerived.callUpcall(myBarFooDerived, fooBar), "overrideDerived;Bar::Foo2::Foo2Bar()");

    director_shared_ptr.Foo myFoo3 = myBarFoo.makeFoo();
    myFoo3.swigReleaseOwnership();
    myFoo3.swigTakeOwnership();
    director_shared_ptr.FooDerived myBarFooDerived2 = new director_shared_ptr_MyBarFooDerived();
    myBarFooDerived2.swigReleaseOwnership();
    myBarFooDerived2.swigTakeOwnership();

  }
}

class director_shared_ptr_MyBarFoo extends director_shared_ptr.Foo {

  @Override
  public String ping() {
    return "director_shared_ptr_MyBarFoo.ping()";
  }

  @Override
  public String pong() {
    return "director_shared_ptr_MyBarFoo.pong();" + ping();
  }

  @Override
  public String upcall(director_shared_ptr.FooBar fooBarPtr) {
    return "override;" + fooBarPtr.FooBarDo();
  }

  @Override
  public director_shared_ptr.Foo makeFoo() {
    return new director_shared_ptr.Foo();
  }
}

class director_shared_ptr_MyBarFooDerived extends director_shared_ptr.FooDerived {

  @Override
  public String ping() {
    return "director_shared_ptr_MyBarFooDerived.ping()";
  }

  @Override
  public String pong() {
    return "director_shared_ptr_MyBarFooDerived.pong();" + ping();
  }

  @Override
  public String upcall(director_shared_ptr.FooBar fooBarPtr) {
    return "overrideDerived;" + fooBarPtr.FooBarDo();
  }

  @Override
  public director_shared_ptr.Foo makeFoo() {
    return new director_shared_ptr.Foo();
  }
}
