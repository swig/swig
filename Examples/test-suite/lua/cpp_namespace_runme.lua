require("import")
require("cpp_namespace")
cn=cpp_namespace
catch_undef_globs() -- catch "undefined" global variables

assert(cn.fact(4) == 24)
assert(cn.Foo == 42)

t1 = cn.Test()
assert(t1:method() == "Test::method")

cn.weird("t1", 4)

assert(cn.do_method(t1) == "Test::method")
assert(cn.do_method2(t1) == "Test::method")

t2 = cn.Test2()
assert(t2:method() == "Test2::method")


assert(cn.foo3(5) == 5)

assert(cn.do_method3(t2, 7) == "Test2::method")
