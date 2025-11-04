var smart_pointer_not = require("smart_pointer_not");

var f = new smart_pointer_not.Foo();
var b = new smart_pointer_not.Bar(f);
var s = new smart_pointer_not.Spam(f);
var g = new smart_pointer_not.Grok(f);

// This is the only that should work
f.getx();

// Accessing an inexistent property in JS
// does not throw - it returns undefined
var fail = false;
try {
    x = b.getx();
    fail = new Error("Error! b.x");
} catch { }
if (fail) throw fail;

try {
    x = s.getx();
    fail = new Error("Error! b.x");
} catch { }
if (fail) throw fail;

try {
    x = g.getx();
    fail = new Error("Error! b.x");
} catch { }
if (fail) throw fail;
