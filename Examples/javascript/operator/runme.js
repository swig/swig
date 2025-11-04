var example = require("example");

var a = new example.Complex(2,3);
var b = new example.Complex(-5,10);

console.log ("a =" + a);
console.log ("b   =" + b);

var c = a.plus(b);

console.log("c   =" + c);
console.log("a*b =" + a.times(b));
console.log("a-c =" + a.minus(c));

var e = example.Complex.copy(a.minus(c));
console.log("e   =" + e);

// Big expression
var f = a.plus(b).times(c.plus(b.times(e))).plus(a.uminus());
console.log("f   =" + f);





