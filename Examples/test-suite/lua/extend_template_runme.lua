require("import")
require("extend_template")
et=extend_template
catch_undef_globs() -- catch "undefined" global variables

foo1 = et.Foo_0()
assert(foo1:test1(5) == 5)
assert(foo1:test2(7) == 7)
