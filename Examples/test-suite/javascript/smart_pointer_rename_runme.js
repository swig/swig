var smart_pointer_rename = require("smart_pointer_rename");

var f = new smart_pointer_rename.Foo();
var b = new smart_pointer_rename.Bar(f);

if (/* await */(b.test()) != 3) {
    throw new Error;
}

if (/* await */(b.ftest1(1)) != 1) {
    throw new Error;
}

if (/* await */(b.ftest2(2, 3)) != 2) {
    throw new Error;
}
