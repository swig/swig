var namespace_class = require("namespace_class");

try {
    p = namespace_class.Private1();
    error = 1;
} catch {
    error = 0;
}

if ((error)) {
    throw new Error("Private1 is private");
}

try {
    p = namespace_class.Private2();
    error = 1;
} catch {
    error = 0;
}

if ((error)) {
    throw new Error("Private2 is private");
}

namespace_class.EulerT3D.toFrame(1, 1, 1);

b = new namespace_class.BooT_i();
b = new namespace_class.BooT_H();


f = new namespace_class.FooT_i();
f.quack(1);

f = new namespace_class.FooT_d();
f.moo(1);

f = new namespace_class.FooT_H();
f.foo(namespace_class.Hi);

// This test works only in Node.js
if (typeof process !== 'undefined') {
    if (!f.constructor.name.includes("FooT_H") || !(f instanceof namespace_class.FooT_H)) {
        throw new Error("Incorrect type: " + f.toString());
    }
}
