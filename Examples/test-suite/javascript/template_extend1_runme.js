var template_extend1 = require("template_extend1");

a = new template_extend1.lBaz();
b = new template_extend1.dBaz();

if (a.foo() != "lBaz::foo") {
    throw new Error;
}

if (b.foo() != "dBaz::foo") {
    throw new Error;
}
