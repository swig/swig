var smart_pointer_overload = require("smart_pointer_overload");

f = new smart_pointer_overload.Foo();
b = new smart_pointer_overload.Bar(f);


if (f.test(3) != 1) {
    throw new Error;
}
if (f.test(3.5) != 2) {
    throw new Error;
}
if (f.test("hello") != 3) {
    throw new Error;
}
if (b.test(3) != 1) {
    throw new Error;
}
if (b.test(3.5) != 2) {
    throw new Error;
}
if (b.test("hello") != 3) {
    throw new Error;
}
