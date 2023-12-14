var overload_simple = require("overload_simple");

if (/* await */(overload_simple.foo(3)) != "foo:int") {
    throw new Error("foo(int)");
}

if (/* await */(overload_simple.foo("hello")) != "foo:char *") {
    throw new Error("foo(char *)");
}

var f = new overload_simple.Foo();
var b = new overload_simple.Bar();

if (/* await */(overload_simple.foo(f)) != "foo:Foo *") {
    throw new Error("foo(Foo *)");
}

if (/* await */(overload_simple.foo(b)) != "foo:Bar *") {
    throw new Error("foo(Bar *)");
}

var v = /* await */(overload_simple.malloc_void(32));

if (/* await */(overload_simple.foo(v)) != "foo:void *") {
    throw new Error("foo(void *)");
}

var s = new overload_simple.Spam();

if (/* await */(s.foo(3)) != "foo:int") {
    throw new Error("Spam::foo(int)");
}

if (/* await */(s.foo("hello")) != "foo:char *") {
    throw new Error("Spam::foo(char *)");
}

if (/* await */(s.foo(f)) != "foo:Foo *") {
    throw new Error("Spam::foo(Foo *)");
}

if (/* await */(s.foo(b)) != "foo:Bar *") {
    throw new Error("Spam::foo(Bar *)");
}

if (/* await */(s.foo(v)) != "foo:void *") {
    throw new Error("Spam::foo(void *)");
}

if (/* await */(overload_simple.Spam.bar(3)) != "bar:int") {
    throw new Error("Spam::bar(int)");
}

if (/* await */(overload_simple.Spam.bar("hello")) != "bar:char *") {
    throw new Error("Spam::bar(char *)");
}

if (/* await */(overload_simple.Spam.bar(f)) != "bar:Foo *") {
    throw new Error("Spam::bar(Foo *)");
}

if (/* await */(overload_simple.Spam.bar(b)) != "bar:Bar *") {
    throw new Error("Spam::bar(Bar *)");
}

if (/* await */(overload_simple.Spam.bar(v)) != "bar:void *") {
    throw new Error("Spam::bar(void *)");
}

// Test constructors

s = new overload_simple.Spam();
if (s.type != "none") {
    throw new Error("Spam()");
}

s = new overload_simple.Spam(3);
if (s.type != "int") {
    throw new Error("Spam(int)");
}

s = new overload_simple.Spam("hello");
if (s.type != "char *") {
    throw new Error("Spam(char *)");
}

s = new overload_simple.Spam(f);
if (s.type != "Foo *") {
    throw new Error("Spam(Foo *)");
}

s = new overload_simple.Spam(b);
if (s.type != "Bar *") {
    throw new Error("Spam(Bar *)");
}

s = new overload_simple.Spam(v);
if (s.type != "void *") {
    throw new Error("Spam(void *)");
}

/* await */(overload_simple.free_void(v));

var a = new overload_simple.ClassA();
var b = /* await */(a.method1(1));
