var template_ns4 = require("template_ns4");

var d = /* await */(template_ns4.make_Class_DD());
if (/* await */(d.test()) != "test") {
    throw new Error;
}
