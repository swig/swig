var extend_template_ns = require("extend_template_ns");
f = new extend_template_ns.Foo_One();
if (f.test1(37) != 37) {
    throw new Error;
}

if (f.test2(42) != 42) {
    throw new Error;
}
