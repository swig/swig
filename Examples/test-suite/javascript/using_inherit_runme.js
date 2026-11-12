var using_inherit = require("using_inherit");

b = new using_inherit.Bar();
if (b.test(3) != 3) {
    throw new Error("Bar::test(int)");
}

if (b.test(3.5) != 3.5) {
    throw new Error("Bar::test(double)");
}


b = new using_inherit.Bar2();
if (b.test(3) != 6) {
    throw new Error("Bar2::test(int)");
}

if (b.test(3.5) != 7.0) {
    throw new Error("Bar2::test(double)");
}


b = new using_inherit.Bar3();
if (b.test(3) != 6) {
    throw new Error("Bar3::test(int)");
}

if (b.test(3.5) != 7.0) {
    throw new Error("Bar3::test(double)");
}


b = new using_inherit.Bar4();
if (b.test(3) != 6) {
    throw new Error("Bar4::test(int)");
}

if (b.test(3.5) != 7.0) {
    throw new Error("Bar4::test(double)");
}


b = new using_inherit.Fred1();
if (b.test(3) != 3) {
    throw new Error("Fred1::test(int)");
}

if (b.test(3.5) != 7.0) {
    throw new Error("Fred1::test(double)");
}


// Alas, currently there is no way to make the JS backends
// prefer integer to floating point - these are applied
// in the declaration order
b = new using_inherit.Fred2();
if (b.test(3) != 6) {
    throw new Error("Fred2::test(int)");
}

if (b.test(3.5) != 7.0) {
    throw new Error("Fred2::test(double)");
}
