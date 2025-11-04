var template_extend1 = require("template_extend1");

var a = new template_extend1.lBaz();
var b = new template_extend1.dBaz();

if (a.foo() != "lBaz::foo") {
    throw new Error;
}

if (b.foo() != "dBaz::foo") {
    throw new Error;
}
