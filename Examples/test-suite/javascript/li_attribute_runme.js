var li_attribute = require("li_attribute");

aa = new li_attribute.A(1, 2, 3);

if (aa.a != 1) {
    throw new Error;
}
aa.a = 3;
if (aa.a != 3) {
    throw new Error("aa.a: {}" + aa.a.toString());
}

if (aa.b != 2) {
    throw new Error("aa.b: {}" + aa.b.toString());
}
aa.b = 5;
if (aa.b != 5) {
    throw new Error;
}

if (aa.d != aa.b) {
    throw new Error;
}

if (aa.c != 3) {
    throw new Error;
}
fail = true;
try {
    aa.c = 5;
} catch (e) {
    fail = false;
}
if (aa.c != 3 || fail) {
    throw new Error;
}

pi = new li_attribute.Param_i(7);
if (pi.value != 7) {
    throw new Error;
}

pi.value = 3;
if (pi.value != 3) {
    throw new Error;
}

b = new li_attribute.B(aa);

if (b.a.c != 3) {
    throw new Error;
}

// class/struct attribute with get/set methods using return/pass by reference
myFoo = new li_attribute.MyFoo();
myFoo.x = 8;
myClass = new li_attribute.MyClass();
myClass.Foo = myFoo;
if (myClass.Foo.x != 8) {
    throw new Error;
}
myClass.Foo2 = myFoo;
if (myClass.Foo2.x != 8) {
    throw new Error;
}

// class/struct attribute with get/set methods using return/pass by value
myClassVal = new li_attribute.MyClassVal();
if (myClassVal.ReadWriteFoo.x != -1) {
    throw new Error;
}
if (myClassVal.ReadOnlyFoo.x != -1) {
    throw new Error;
}
myClassVal.ReadWriteFoo = myFoo;
if (myClassVal.ReadWriteFoo.x != 8) {
    throw new Error;
}
if (myClassVal.ReadOnlyFoo.x != 8) {
    throw new Error;
}

// string attribute with get/set methods using return/pass by value
myStringyClass = new li_attribute.MyStringyClass("initial string");
if (myStringyClass.ReadWriteString != "initial string") {
    throw new Error;
}
if (myStringyClass.ReadOnlyString != "initial string") {
    throw new Error;
}
myStringyClass.ReadWriteString = "changed string";
if (myStringyClass.ReadWriteString != "changed string") {
    throw new Error;
}
if (myStringyClass.ReadOnlyString != "changed string") {
    throw new Error;
}

// In JS, accessing a non-existing attribute does not throw, it returns undefined
if (myFoo.does_not_exist !== undefined) {
    throw new Error;
}
// Additionally, creating attributes is always possible unless the object is frozen
myFoo.does_not_exist = 'value';
if (myFoo.does_not_exist !== 'value') {
    throw new Error;
}
