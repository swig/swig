var typemap_documentation = require("typemap_documentation");

f = new typemap_documentation.Foo();
f.x = 55;
b = new typemap_documentation.Bar();
b.y = 44;

if (55 != typemap_documentation.GrabVal(f)) {
    throw new Error("bad value");
}

try {
    typemap_documentation.GrabVal(b);
} catch (e) {
    // This is working only in NAPI, other backends throw generic errors
    //if (!(e instanceof TypeError))
    //    throw e;
    if (!e.message.includes('expecting type Foo'))
        throw e;
}

if (55 != typemap_documentation.GrabValFooBar(f)) {
    throw new Error("bad f value");
}
if (44 != typemap_documentation.GrabValFooBar(b)) {
    throw new Error("bad b value");
}
