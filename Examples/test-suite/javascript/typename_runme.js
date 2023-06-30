var typename = require("typename");
f = new typename.Foo();
b = new typename.Bar();

x = typename.twoFoo(f);
if (typeof x !== 'number') {
    throw new Error("Wrong return type (FloatType) !");
}
y = typename.twoBar(b);
if (typeof y !== 'number') {
    throw new Error("Wrong return type (IntType)!");
}
