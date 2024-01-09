var template_inherit = require("template_inherit");
var a = new template_inherit.FooInt();
var b = new template_inherit.FooDouble();
var c = new template_inherit.BarInt();
var d = new template_inherit.BarDouble();
var e = new template_inherit.FooUInt();
var f = new template_inherit.BarUInt();

if (/* await */(a.blah()) != "Foo") {
    throw new Error;
}

if (/* await */(b.blah()) != "Foo") {
    throw new Error;
}

if (/* await */(e.blah()) != "Foo") {
    throw new Error;
}

if (/* await */(c.blah()) != "Bar") {
    throw new Error;
}

if (/* await */(d.blah()) != "Bar") {
    throw new Error;
}

if (/* await */(f.blah()) != "Bar") {
    throw new Error;
}

if (/* await */(c.foomethod()) != "foomethod") {
    throw new Error;
}

if (/* await */(d.foomethod()) != "foomethod") {
    throw new Error;
}

if (/* await */(f.foomethod()) != "foomethod") {
    throw new Error;
}

if (/* await */(template_inherit.invoke_blah_int(a)) != "Foo") {
    throw new Error;
}

if (/* await */(template_inherit.invoke_blah_int(c)) != "Bar") {
    throw new Error;
}

if (/* await */(template_inherit.invoke_blah_double(b)) != "Foo") {
    throw new Error;
}

if (/* await */(template_inherit.invoke_blah_double(d)) != "Bar") {
    throw new Error;
}

if (/* await */(template_inherit.invoke_blah_uint(e)) != "Foo") {
    throw new Error;
}

if (/* await */(template_inherit.invoke_blah_uint(f)) != "Bar") {
    throw new Error;
}
