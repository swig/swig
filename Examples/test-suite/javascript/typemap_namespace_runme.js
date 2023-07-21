var typemap_namespace = require("typemap_namespace");

if (/* await */(typemap_namespace.test1("hello")) != "hello")
    throw "RuntimeError";

if (/* await */(typemap_namespace.test2("hello")) != "hello")
    throw "RuntimeError";
