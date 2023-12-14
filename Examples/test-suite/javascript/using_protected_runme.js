var using_protected = require("using_protected");

var f = new using_protected.FooBar();
f.x = 3;

if (/* await */(f.blah(4)) != 4) {
    throw new Error("blah(int)");
}
