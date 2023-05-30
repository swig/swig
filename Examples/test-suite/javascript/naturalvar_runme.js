var naturalvar = require("naturalvar");

f = new naturalvar.Foo();
b = new naturalvar.Bar();

b.f = f;

naturalvar.s = "hello";
b.s = "hello";

if (b.s != naturalvar.s) {
    throw new Error;
}
