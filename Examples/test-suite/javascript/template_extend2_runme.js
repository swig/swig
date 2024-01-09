var template_extend2 = require("template_extend2");

var a = new template_extend2.lBaz();
var b = new template_extend2.dBaz();

if (/* await */(a.foo()) != "lBaz::foo") {
    throw new Error;
}

if (/* await */(b.foo()) != "dBaz::foo") {
    throw new Error;
}
