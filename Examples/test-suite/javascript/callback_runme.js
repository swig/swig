var callback = require("callback");

if (/* await */(callback.foo(2)) !== 2) {
  throw new Error("Failed.");
}
if (/* await */(callback.A_bar(2)) !== 4) {
  throw new Error("Failed.");
}
if (/* await */(callback.foobar(3, callback.foo)) != callback.foo(3)) {
  throw new Error("Failed.");
}
if (/* await */(callback.foobar(3, foo)) != callback.foo(3)) {
  throw new Error("Failed.");
}
if (/* await */(callback.foobar(3, callback.A_bar)) != callback.A_bar(3)) {
  throw new Error("Failed.");
}
if (/* await */(callback.foobar(3, callback.foof)) != callback.foof(3)) {
  throw new Error("Failed.");
}
if (/* await */(callback.foobar_i(3, callback.foo_i)) != callback.foo_i(3)) {
  throw new Error("Failed.");
}
if (/* await */(callback.foobar_d(3.5, callback.foo_d)) != callback.foo_d(3.5)) {
  throw new Error("Failed.");
}
var a = new callback.A();
if (/* await */(callback.foobarm(3, a, callback.A.foom_cb_ptr)) != a.foom(3)) {
  throw new Error("Failed.");
}
