require("import")
require("enum_template")
et=enum_template
catch_undef_globs() -- catch "undefined" global variables

assert(et.eTest0 ~= nil)
assert(et.eTest1 ~= nil)

et.TakeETest(et.eTest0)

res = et.MakeETest()
et.TakeETest(res)
