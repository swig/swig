var using_composition = require("using_composition");

f = new using_composition.FooBar();
if (f.blah(3) != 3) {
    throw new Error("FooBar::blah(int)");
}

if (f.blah(3.5) != 3.5) {
    throw new Error("FooBar::blah(double)");
}

if (f.blah("hello") != "hello") {
    throw new Error("FooBar::blah(char *)");
}


f = new using_composition.FooBar2();
if (f.blah(3) != 3) {
    throw new Error("FooBar2::blah(int)");
}

if (f.blah(3.5) != 3.5) {
    throw new Error("FooBar2::blah(double)");
}

if (f.blah("hello") != "hello") {
    throw new Error("FooBar2::blah(char *)");
}


f = new using_composition.FooBar3();
if (f.blah(3) != 3) {
    throw new Error("FooBar3::blah(int)");
}

if (f.blah(3.5) != 3.5) {
    throw new Error("FooBar3::blah(double)");
}

if (f.blah("hello") != "hello") {
    throw new Error("FooBar3::blah(char *)");
}
