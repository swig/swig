var using_private = require("using_private");

var f = new using_private.FooBar();
f.x = 3;

if (/* await */(f.blah(4)) != 4) {
    throw new Error("blah(int)");
}

if (/* await */(f.defaulted()) != -1) {
    throw new Error("defaulted()");
}

if (/* await */(f.defaulted(222)) != 222) {
    throw new Error("defaulted(222)");
}
