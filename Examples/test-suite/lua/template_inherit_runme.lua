require("import")
require("template_inherit")
ti=template_inherit
catch_undef_globs() -- catch "undefined" global variables

fi = ti.FooInt()
assert(fi:blah() == "Foo")
assert(fi:foomethod() == "foomethod")

bi = ti.BarInt()
assert(bi:blah() == "Bar")
assert(bi:foomethod() == "foomethod")

assert(ti.invoke_blah_int(fi) == "Foo")
assert(ti.invoke_blah_int(bi) == "Bar")

bd = ti.BarDouble()
success = pcall(ti.invoke_blah_int, bd)
assert(not success)
