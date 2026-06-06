var using_private = require("using_private");

f = new using_private.FooBar();
f.x = 3;

if (f.blah(4) != 4) {
    throw new Error("blah(int)");
}

if (f.defaulted() != -1) {
    throw new Error("defaulted()");
}

if (f.defaulted(222) != 222) {
    throw new Error("defaulted(222)");
}
