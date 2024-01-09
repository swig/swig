var namespace_class = require("namespace_class");

try {
  /* @ts-ignore */
    var p = /* await */(namespace_class.Private1());
    var error = 1;
} catch {
    error = 0;
}

if ((error)) {
    throw new Error("Private1 is private");
}

try {
  /* @ts-ignore */
    p = /* await */(namespace_class.Private2());
    error = 1;
} catch {
    error = 0;
}

if ((error)) {
    throw new Error("Private2 is private");
}

/* await */(namespace_class.EulerT3D.toFrame(1, 1, 1));

var b = new namespace_class.BooT_i();
b = new namespace_class.BooT_H();


var f = new namespace_class.FooT_i();
/* await */(f.quack(1));

var f2 = new namespace_class.FooT_d();
/* await */(f2.moo(1));

var f3 = new namespace_class.FooT_H();
/* await */(f3.foo(namespace_class.Hi));

// This test works only in Node.js
if (typeof globalThis.process !== 'undefined') {
    if (!f3.constructor.name.includes("FooT_H") || !(f3 instanceof namespace_class.FooT_H)) {
        throw new Error("Incorrect type: " + f2.toString());
    }
}
