module li_attribute_runme;

import li_attribute.A;
import li_attribute.B;
import li_attribute.MyClass;
import li_attribute.MyClassVal;
import li_attribute.MyStringyClass;
import li_attribute.MyFoo;
import li_attribute.Param_i;

void main() {
  auto aa = new A(1,2,3);

  if (aa.a != 1)
    throw new Exception("error");
  aa.a = 3;
  if (aa.a != 3)
    throw new Exception("error");

  if (aa.b != 2)
    throw new Exception("error");
  aa.b = 5;
  if (aa.b != 5)
    throw new Exception("error");

  if (aa.d != aa.b)
    throw new Exception("error");

  if (aa.c != 3)
    throw new Exception("error");

  auto pi = new Param_i(7);
  if (pi.value != 7)
    throw new Exception("error");

  pi.value=3;
  if (pi.value != 3)
    throw new Exception("error");

  auto b = new B(aa);
  if (b.a.c != 3)
    throw new Exception("error");

  // class/struct attribute with get/set methods using return/pass by reference
  auto myFoo = new MyFoo();
  myFoo.x = 8;
  auto myClass = new MyClass();
  myClass.Foo = myFoo;
  if (myClass.Foo.x != 8)
    throw new Exception("error");

  // class/struct attribute with get/set methods using return/pass by value
  auto myClassVal = new MyClassVal();
  if (myClassVal.ReadWriteFoo.x != -1)
    throw new Exception("error");
  if (myClassVal.ReadOnlyFoo.x != -1)
    throw new Exception("error");
  myClassVal.ReadWriteFoo = myFoo;
  if (myClassVal.ReadWriteFoo.x != 8)
    throw new Exception("error");
  if (myClassVal.ReadOnlyFoo.x != 8)
    throw new Exception("error");

  // string attribute with get/set methods using return/pass by value
  auto myStringClass = new MyStringyClass("initial string");
  if (myStringClass.ReadWriteString != "initial string")
    throw new Exception("error");
  if (myStringClass.ReadOnlyString != "initial string")
    throw new Exception("error");
  myStringClass.ReadWriteString = "changed string";
  if (myStringClass.ReadWriteString != "changed string")
    throw new Exception("error");
  if (myStringClass.ReadOnlyString != "changed string")
    throw new Exception("error");
}
