var naturalvar = require("naturalvar");

var f = new naturalvar.Foo();
var b = new naturalvar.Bar();

b.f = f;

naturalvar.s = "hello";
b.s = "hello";

if (b.s != naturalvar.s) {
    throw new Error;
}
