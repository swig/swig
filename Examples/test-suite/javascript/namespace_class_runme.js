var namespace_class = require("namespace_class");

try {
    var p = /* await */(namespace_class.Private1());
    var error = 1;
} catch {
    error = 0;
}

if ((error)) {
    throw new Error("Private1 is private");
}

try {
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

f = new namespace_class.FooT_d();
/* await */(f.moo(1));

f = new namespace_class.FooT_H();
/* await */(f.foo(namespace_class.Hi));

// This test works only in Node.js
if (typeof process !== 'undefined') {
    if (!f.constructor.name.includes("FooT_H") || !(f instanceof namespace_class.FooT_H)) {
        throw new Error("Incorrect type: " + f.toString());
    }
}
