module director_basic_runme;

import director_basic.A1;
import director_basic.Bar;
import director_basic.Foo;
import director_basic.MyClass;

void main() {
  auto a = new director_basic_MyFoo();
  if (a.ping() != "director_basic_MyFoo::ping()") {
    throw new Exception("a.ping()");
  }
  if (a.pong() != "Foo::pong();director_basic_MyFoo::ping()") {
    throw new Exception("a.pong()");
  }

  auto b = new Foo();
  if (b.ping() != "Foo::ping()") {
    throw new Exception("b.ping()");
  }
  if (b.pong() != "Foo::pong();Foo::ping()") {
    throw new Exception("b.pong()");
  }

  {
    scope a1 = new A1(1, false);
  }

  {
    auto my = new MyOverriddenClass();

    my.expectNull = true;
    if (MyClass.call_pmethod(my, null) !is null)
      throw new Exception("null pointer conversion problem");

    auto myBar = new Bar();
    my.expectNull = false;
    auto myNewBar = MyClass.call_pmethod(my, myBar);
    if (myNewBar is null)
      throw new Exception("non-null pointer conversion problem");
    myNewBar.x = 10;
  }
}

class director_basic_MyFoo : Foo {
  public override char[] ping() {
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
