var input = require("input");

var f = new input.Foo();
if (/* await */(f.foo(2)) != 4) {
    throw new Error;
}

if (/* await */(f.foo(null)) != null) {
    throw new Error;
}

if (/* await */(f.foo()) != null) {
    throw new Error;
}

if (/* await */(input.sfoo("Hello")) != "Hello world") {
    throw new Error;
}

if (/* await */(input.sfoo()) != null) {
    throw new Error;
}
