var template_ns4 = require("template_ns4");

d = template_ns4.make_Class_DD();
if (d.test() != "test") {
    throw new Error;
}
