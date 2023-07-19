var overload_extend_c = require("overload_extend_c");

var f = new overload_extend_c.Foo();
if (/* await */(f.test()) != 0) {
    throw new Error;
}
if (/* await */(f.test(3)) != 1) {
    throw new Error;
}
if (/* await */(f.test("hello")) != 2) {
    throw new Error;
}
if (/* await */(f.test(3, 2)) != 5) {
    throw new Error;
}
// In JavaScript there is no difference between 3.0 and 3
if (/* await */(f.test(3.0)) != 1) {
    throw new Error;
}
