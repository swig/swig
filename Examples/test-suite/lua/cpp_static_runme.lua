-- demo of lua swig capacilities (operator overloading)
require("import")
require("cpp_static")
cs=cpp_static
catch_undef_globs() -- catch "undefined" global variables

cs.StaticMemberTest.static_int = 5
assert(cs.StaticMemberTest.static_int == 5)

cs.StaticFunctionTest.static_func()
cs.StaticFunctionTest.static_func_2(2)
cs.StaticFunctionTest.static_func_3(3,3)
