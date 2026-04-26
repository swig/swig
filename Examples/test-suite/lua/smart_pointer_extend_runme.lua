require("import")
require("smart_pointer_extend")
spe=smart_pointer_extend
catch_undef_globs() -- catch "undefined" global variables

assert(spe.CBase.hello() == 1)
assert(spe.CBase.z == 1)

base1 = spe.CBase()
base1.x = 7

p1 = spe.CPtr()

assert(spe.get_hello(p1) == 1)
assert(p1:foo() == 1)
assert(p1:bar() == 2)
assert(p1:boo(5) == 5)

foo = spe.Foo()
bar = spe.Bar(foo)

assert(bar:extension(5,7) == 5)
assert(bar:extension(7) == 7)
assert(bar:extension() == 1)

dfoo = spe.DFoo()
dptr = spe.DPtrFoo(dfoo)

assert(dptr:Ext() == 2)
assert(dptr:Ext(5) == 5)
