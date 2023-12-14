var overload_extend2 = require("overload_extend2");

var f = new overload_extend2.Foo();
if (/* await */(f.test(3)) != 1) {
    throw new Error;
}
if (/* await */(f.test("hello")) != 2) {
    throw new Error;
}
if (/* await */(f.test(3.5, 2.5)) != 3) {
    throw new Error;
}
if (/* await */(f.test("hello", 20)) != 1020) {
    throw new Error;
}
if (/* await */(f.test("hello", 20, 100)) != 120) {
    throw new Error;
}

// C default args
if (/* await */(f.test(f)) != 30) {
    throw new Error;
}
if (/* await */(f.test(f, 100)) != 120) {
    throw new Error;
}
if (/* await */(f.test(f, 100, 200)) != 300) {
    throw new Error;
}
