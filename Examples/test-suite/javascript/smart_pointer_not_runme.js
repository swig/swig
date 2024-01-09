var smart_pointer_not = require("smart_pointer_not");

var f = new smart_pointer_not.Foo();
var b = new smart_pointer_not.Bar(f);
var s = new smart_pointer_not.Spam(f);
var g = new smart_pointer_not.Grok(f);

// This is the only that should work
/* await */(f.getx());

// Accessing an inexistent property in JS
// does not throw - it returns undefined
// (but calling it as a function throws)
var fail = false;
try {
  /* @ts-ignore */
  var x = /* await */(b.getx());
  /* @ts-ignore */
  fail = new Error("Error! b.x");
} catch { }
if (fail) throw fail;

try {
  /* @ts-ignore */
  x = s.getx();
  /* @ts-ignore */
  fail = new Error("Error! b.x");
} catch { }
if (fail) throw fail;

try {
  /* @ts-ignore */
  x = g.getx();
  /* @ts-ignore */
  fail = new Error("Error! b.x");
} catch { }
if (fail) throw fail;
