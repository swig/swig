var using_protected = require("using_protected");

f = new using_protected.FooBar();
f.x = 3;

if (f.blah(4) != 4) {
    throw new Error("blah(int)");
}
