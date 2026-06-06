var smart_pointer_not = require("smart_pointer_not");

f = new smart_pointer_not.Foo();
b = new smart_pointer_not.Bar(f);
s = new smart_pointer_not.Spam(f);
g = new smart_pointer_not.Grok(f);

// This is the only that should work
f.getx();

// Accessing an inexistent property in JS
// does not throw - it returns undefined
fail = false;
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
