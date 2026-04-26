require("import")
require("smart_pointer_rename")
spr=smart_pointer_rename
catch_undef_globs() -- catch "undefined" global variables

foo = spr.Foo()
assert(foo:ftest1(1) == 1)
assert(foo:ftest2(1,2) == 2)

bar = spr.Bar(foo)
assert(bar:test() == 3)
assert(bar:ftest1(1) == 1)
assert(bar:ftest2(1,2) == 2)
