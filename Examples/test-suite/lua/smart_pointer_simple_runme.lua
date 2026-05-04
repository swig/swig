require("import")
require("smart_pointer_simple")
sps=smart_pointer_simple
catch_undef_globs() -- catch "undefined" global variables

foo1 = sps.Foo()
foo1.x = 5
assert(foo1.x == 5)
assert(foo1:getx() == 5)

bar1 = sps.Bar(foo1)
bar1.x = 3
assert(bar1.x == 3)
assert(bar1:getx() == 3)

bar1.x = 5
assert(bar1.x == 5)
assert(bar1:getx() == 5)
