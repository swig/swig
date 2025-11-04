var typename = require("typename");
var f = new typename.Foo();
var b = new typename.Bar();

var x = typename.twoFoo(f);
if (typeof x !== 'number') {
    throw new Error("Wrong return type (FloatType) !");
}
var y = typename.twoBar(b);
if (typeof y !== 'number') {
    throw new Error("Wrong return type (IntType)!");
}
