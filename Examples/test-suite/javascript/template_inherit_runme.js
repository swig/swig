var template_inherit = require("template_inherit");
a = new template_inherit.FooInt();
b = new template_inherit.FooDouble();
c = new template_inherit.BarInt();
d = new template_inherit.BarDouble();
e = new template_inherit.FooUInt();
f = new template_inherit.BarUInt();

if (a.blah() != "Foo") {
    throw new Error;
}

if (b.blah() != "Foo") {
    throw new Error;
}

if (e.blah() != "Foo") {
    throw new Error;
}

if (c.blah() != "Bar") {
    throw new Error;
}

if (d.blah() != "Bar") {
    throw new Error;
}

if (f.blah() != "Bar") {
    throw new Error;
}

if (c.foomethod() != "foomethod") {
    throw new Error;
}

if (d.foomethod() != "foomethod") {
    throw new Error;
}

if (f.foomethod() != "foomethod") {
    throw new Error;
}

if (template_inherit.invoke_blah_int(a) != "Foo") {
    throw new Error;
}

if (template_inherit.invoke_blah_int(c) != "Bar") {
    throw new Error;
}

if (template_inherit.invoke_blah_double(b) != "Foo") {
    throw new Error;
}

if (template_inherit.invoke_blah_double(d) != "Bar") {
    throw new Error;
}

if (template_inherit.invoke_blah_uint(e) != "Foo") {
    throw new Error;
}

if (template_inherit.invoke_blah_uint(f) != "Bar") {
    throw new Error;
}
