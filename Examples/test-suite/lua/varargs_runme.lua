require("import")
require("varargs")
v=varargs
catch_undef_globs() -- catch "undefined" global variables

assert(v.test("Hello") == "Hello")
assert(v.test_def("Hello",0) == "Hello")

assert(v.Foo.statictest("Hello") == "Hello")
assert(v.Foo.statictest("Hello",1) == "Hello")

assert(v.test_plenty("Hello") == "Hello")
assert(v.test_plenty("Hello",1) == "Hello")
assert(v.test_plenty("Hello",1,2) == "Hello")
