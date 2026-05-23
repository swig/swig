using director_shared_ptrNamespace;
using System;

public class runme
{
  private class director_shared_ptr_MyBarFoo : Foo
  {
    public override string ping()
    {
      return "director_shared_ptr_MyBarFoo.ping()";
    }

    public override string pong()
    {
      return "director_shared_ptr_MyBarFoo.pong();" + ping();
    }

    public override string upcall(FooBar fooBarPtr)
    {
      return "override;" + fooBarPtr.FooBarDo();
    }

    public override Foo makeFoo()
    {
      return new Foo();
    }
  }

  private class director_shared_ptr_MyBarFooDerived : FooDerived
  {
    public override string ping()
    {
      return "director_shared_ptr_MyBarFooDerived.ping()";
    }

    public override string pong()
    {
      return "director_shared_ptr_MyBarFooDerived.pong();" + ping();
    }

    public override string upcall(FooBar fooBarPtr)
    {
      return "overrideDerived;" + fooBarPtr.FooBarDo();
    }

    public override Foo makeFoo()
    {
      return new Foo();
    }
  }

  private static void check(string got, string expected)
  {
    if (got != expected)
      throw new ApplicationException("Failed, got: " + got + " expected: " + expected);
  }

  static void Main()
  {
    FooBar fooBar = new FooBar();

    Foo myBarFoo = new director_shared_ptr_MyBarFoo();
    check(myBarFoo.ping(), "director_shared_ptr_MyBarFoo.ping()");
    check(Foo.callPong(myBarFoo), "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()");
    check(Foo.callUpcall(myBarFoo, fooBar), "override;Bar::Foo2::Foo2Bar()");

    Foo myFoo = myBarFoo.makeFoo();
    check(myFoo.pong(), "Foo::pong();Foo::ping()");
    check(Foo.callPong(myFoo), "Foo::pong();Foo::ping()");
    check(myFoo.upcall(new FooBar()), "Bar::Foo2::Foo2Bar()");

    Foo myFoo2 = new Foo().makeFoo();
    check(myFoo2.pong(), "Foo::pong();Foo::ping()");
    check(Foo.callPong(myFoo2), "Foo::pong();Foo::ping()");

    FooDerived myBarFooDerived = new director_shared_ptr_MyBarFooDerived();
    check(myBarFooDerived.ping(), "director_shared_ptr_MyBarFooDerived.ping()");
    check(FooDerived.callPong(myBarFooDerived), "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()");
    check(FooDerived.callUpcall(myBarFooDerived, fooBar), "overrideDerived;Bar::Foo2::Foo2Bar()");

  }
}
