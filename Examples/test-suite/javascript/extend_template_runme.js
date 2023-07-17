var extend_template = require("extend_template");

var f = new extend_template.Foo_0();
if (/* await */(f.test1(37)) != 37) {
    throw new Error;
}

if (/* await */(f.test2(42)) != 42) {
    throw new Error;
}
