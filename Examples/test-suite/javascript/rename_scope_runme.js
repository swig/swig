var rename_scope = require("rename_scope");

var a = new rename_scope.Natural_UP();
var b = new rename_scope.Natural_BP();

if (/* await */(a.rtest()) !== 1) {
  throw new Error("a.rtest(): Expected 1, was " + /* await */(a.rtest()));
}

if (/* await */(b.rtest()) !== 1) {
  throw new Error("b.rtest(): Expected 1, was " + /* await */(b.rtest()));
}

var f = rename_scope.equals;
if (f === undefined) {
  throw new Error("Equality operator has not been renamed.");
}
