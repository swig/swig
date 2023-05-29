var input = require("input");

f = new input.Foo();
if (f.foo(2) != 4) {
    throw new Error;
}

if (f.foo(null) != null) {
    throw new Error;
}

if (f.foo() != null) {
    throw new Error;
}

if (input.sfoo("Hello") != "Hello world") {
    throw new Error;
}

if (input.sfoo() != null) {
    throw new Error;
}
