var overload_extend = require("overload_extend")

f = new overload_extend.Foo()
if (f.test() != 0) {
    throw new Error
}
if (f.test(3) != 1) {
    throw new Error
}
if (f.test("hello") != 2) {
    throw new Error
}
if (f.test(3, 2) != 5) {
    throw new Error
}
// In JavaScript there is no difference between 3.0 and 3
if (f.test(3.0) != 1) {
    throw new Error
}
