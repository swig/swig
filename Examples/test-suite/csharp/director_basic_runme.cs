using System;

namespace director_basicNamespace {

public class runme
{
  static void Main() 
  {
    runme r = new runme();
    r.run();
  }

  void run()
  {
    director_basic_MyFoo a = new director_basic_MyFoo();

    if (a.ping() != "director_basic_MyFoo::ping()") {
      throw new Exception ( "a.ping()" );
    }

    if (a.pong() != "Foo::pong();director_basic_MyFoo::ping()") {
      throw new Exception ( "a.pong()" );
    }

    Foo b = new Foo();

    if (b.ping() != "Foo::ping()") {
      throw new Exception ( "b.ping()" );
    }

    if (b.pong() != "Foo::pong();Foo::ping()") {
      throw new Exception ( "b.pong()" );
    }

    A1 a1 = new A1(1, false);
    a1.Dispose();

    {
      MyOverriddenClass my = new MyOverriddenClass();

      my.expectNull = true;
      if (MyClass.call_pmethod(my, null) != null)
        throw new Exception("null pointer marshalling problem");

      Bar myBar = new Bar();
      my.expectNull = false;
      Bar myNewBar = MyClass.call_pmethod(my, myBar);
      if (myNewBar == null)
        throw new Exception("non-null pointer marshalling problem");
      myNewBar.x = 10;

      // Low level implementation check
      my.testSwigDerivedClassHasMethod();

      // These should not call the C# implementations as they are not overridden
      int v;
      v = MyClass.call_nonVirtual(my);
      if (v != 100) throw new Exception("call_nonVirtual broken() " + v);

      v = MyClass.call_nonOverride(my);
      if (v != 101) throw new Exception("call_nonOverride broken() " + v);

      // A mix of overridden and non-overridden
      MyClassEnd myend = new MyClassEnd();
      MyClass mc = myend;

      v = mc.nonVirtual();
      if (v != 202) throw new Exception("mc.nonVirtual() broken " + v);

      v = MyClass.call_nonVirtual(mc);
      if (v != 202) throw new Exception("call_nonVirtual(mc) broken " + v);

      v = MyClass.call_nonVirtual(myend);
      if (v != 202) throw new Exception("call_nonVirtual(myend) broken" + v);

      v = MyClass.call_nonOverride(mc);
      if (v != 101) throw new Exception("call_nonOverride(mc) broken" + v);

      v = MyClass.call_nonOverride(myend);
      if (v != 101) throw new Exception("call_nonOverride(myend) broken" + v);
    }
  }
}

class director_basic_MyFoo : Foo {
  public director_basic_MyFoo() : base() {
  }

  public override string ping() {
    return "director_basic_MyFoo::ping()";
  }
}

class MyOverriddenClass : MyClass {
  public bool expectNull = false;
  public bool nonNullReceived = false;
  public override Bar pmethod(Bar b) {
    if ( expectNull && (b != null) )
      throw new Exception("null not received as expected");
    return b;
  }

  public new bool nonVirtual() {
    throw new Exception("non-virtual overrides virtual method");
  }

  public new virtual bool nonOverride() {
    throw new Exception("non-override overrides virtual method");
  }
}

class MyClassMiddle : MyClass {
  public override int nonVirtual() {
    return 202;
  }
}

class MyClassEnd : MyClassMiddle {
  public new bool nonVirtual() {
    throw new Exception("non-virtual overrides virtual method");
  }

  public new virtual bool nonOverride() {
    throw new Exception("non-override overrides virtual method");
  }
}

}
