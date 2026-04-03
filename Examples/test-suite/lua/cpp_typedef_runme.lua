require("import")
require("cpp_typedef")
ct = cpp_typedef
catch_undef_globs() -- catch "undefined" global variables

foo1 = ct.Foo()
bar1 = foo1:bar()
bar2 = ct.Foo.sbar()

u1 = ct.UnnamedStruct()
n1 = ct.TypedefNamedStruct()

test = ct.Test()

u2 = test:test1(u1)
n2 = test:test2(n1)
n3 = test:test3(n1)
n4 = test:test4(n1)
