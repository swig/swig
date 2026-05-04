require("import")
require("iadd")
i=iadd
catch_undef_globs() -- catch "undefined" global variables

foo1 = i.Foo()
foo1_a = foo1.AsA
assert(foo1_a.x == 5)
assert(foo1_a:get_me().x == 5)
-- Unfortunately, in Lua operator+= can't be overloaded

foo1.AsLong = 1000
assert(foo1.AsLong == 1000)
