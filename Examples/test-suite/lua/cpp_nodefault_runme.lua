require("import")
require("cpp_nodefault")
cn=cpp_nodefault
catch_undef_globs() -- catch "undefined" global variables

foo1 = cn.Foo(1,2)
foo1.a = 5
assert(foo1.a == 5)

foo2 = cn.create(1,2)

cn.consume(foo1,foo2)

bar1 = cn.Bar()
bar1:consume(cn.gvar, foo2)
foo3 = bar1:create(1,2)

foo3.a = 6
assert(foo3.a == 6)
