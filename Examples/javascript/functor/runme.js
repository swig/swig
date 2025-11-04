var example = require("example");

var a = new example.intSum(1);
var b = new example.doubleSum(100.0);
var c = new example.intSum();

// Use the objects.  They should be callable just like a normal
// javascript function.

for (let i=1;i<=100;i++) {
    a.call(i);                // Note: function call
    b.call(Math.sqrt(i));     // Note: function call
    c.call(i);
}

console.log(a.result());
console.log(b.result());
console.log(c.result());

