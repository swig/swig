var example = require("./build/Release/example");

console.log("Global variable Foo=" + example.nspace.Foo);
example.nspace.Foo = 5;
console.log("Variable Foo changed to " + example.nspace.Foo);
console.log("GCD of number 6,18 is " + example.nspace.gcd(6,18));

console.log("Creating some objects:");
c = new example.nspace.Circle(10);
console.log("area = " + c.area());
