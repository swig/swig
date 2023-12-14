var class_scope_weird = require("class_scope_weird");

var f = new class_scope_weird.Foo();
var g = new class_scope_weird.Foo(3);
if (/* await */(f.bar(3)) != 3)
    throw RuntimeError;

// Test missing new keyword during constructor call
var caughtException = false;
try {
  g = /* await */(class_scope_weird.Foo(4));
} catch (err) {
  caughtException = true;
}
if (!caughtException) {
  throw new Error("Instantiation exception not thrown");
}
