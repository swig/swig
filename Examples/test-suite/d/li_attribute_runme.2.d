module li_attribute_runme;

import std.exception;
import li_attribute.A;
import li_attribute.B;
import li_attribute.MyClass;
import li_attribute.MyClassVal;
import li_attribute.MyStringyClass;
import li_attribute.MyFoo;
import li_attribute.Param_i;

void main() {
  auto aa = new A(1,2,3);

  enforce(aa.a == 1);
  aa.a = 3;
  enforce(aa.a == 3);

  enforce(aa.b == 2);
  aa.b = 5;
  enforce(aa.b == 5);

  enforce(aa.d == aa.b);

  enforce(aa.c == 3);

  auto pi = new Param_i(7);
  enforce(pi.value == 7);

  pi.value=3;
  enforce(pi.value == 3);

  auto b = new B(aa);
  enforce(b.a.c == 3);

  // class/struct attribute with get/set methods using return/pass by reference
  auto myFoo = new MyFoo();
  myFoo.x = 8;
  auto myClass = new MyClass();
  myClass.Foo = myFoo;
  enforce(myClass.Foo.x == 8);

  // class/struct attribute with get/set methods using return/pass by value
  auto myClassVal = new MyClassVal();
  enforce(myClassVal.ReadWriteFoo.x == -1);
  enforce(myClassVal.ReadOnlyFoo.x == -1);
  myClassVal.ReadWriteFoo = myFoo;
  enforce(myClassVal.ReadWriteFoo.x == 8);
  enforce(myClassVal.ReadOnlyFoo.x == 8);

  // string attribute with get/set methods using return/pass by value
  auto myStringClass = new MyStringyClass("initial string");
  enforce(myStringClass.ReadWriteString == "initial string");
  enforce(myStringClass.ReadOnlyString == "initial string");
  myStringClass.ReadWriteString = "changed string";
  enforce(myStringClass.ReadWriteString == "changed string");
  enforce(myStringClass.ReadOnlyString == "changed string");
}
