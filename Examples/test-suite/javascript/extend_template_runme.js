var extend_template = require("extend_template");

f = new extend_template.Foo_0();
if (f.test1(37) != 37) {
    throw new Error;
}

if (f.test2(42) != 42) {
    throw new Error;
}
