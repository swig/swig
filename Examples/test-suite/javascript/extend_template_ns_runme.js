var extend_template_ns = require("extend_template_ns");
var f = new extend_template_ns.Foo_One();
if (/* await */(f.test1(37)) != 37) {
    throw new Error;
}

if (/* await */(f.test2(42)) != 42) {
    throw new Error;
}
