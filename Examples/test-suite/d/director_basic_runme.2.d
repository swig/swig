module director_basic_runme;

import std.exception;
import director_basic.A1;
import director_basic.Bar;
import director_basic.Foo;
import director_basic.MyClass;

void main() {
  auto a = new director_basic_MyFoo();
  enforce(a.ping() == "director_basic_MyFoo::ping()", "a.ping()");
  enforce(a.pong() == "Foo::pong();director_basic_MyFoo::ping()", "a.pong()");

  auto b = new Foo();
  enforce(b.ping() == "Foo::ping()", "b.ping()");
  enforce(b.pong() == "Foo::pong();Foo::ping()", "b.pong()");

  {
    scope a1 = new A1(1, false);
  }

  auto my = new MyOverriddenClass();
  my.expectNull = true;
  enforce(MyClass.call_pmethod(my, null) is null, "null pointer conversion problem");
  auto myBar = new Bar();
  my.expectNull = false;
  auto myNewBar = MyClass.call_pmethod(my, myBar);
  enforce(myNewBar !is null, "non-null pointer conversion problem");
  myNewBar.x = 10;
}

class director_basic_MyFoo : Foo {
  public override string ping() {
    return "director_basic_MyFoo::ping()";
  }
}

class MyOverriddenClass : MyClass {
  public bool expectNull = false;
  public bool nonNullReceived = false;
  public override Bar pmethod(Bar b) {
    if (expectNull && (b !is null))
      throw new Exception("null not received as expected");
    return b;
  }
}
