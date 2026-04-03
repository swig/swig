require("import")
require("global_vars")
gv=global_vars
catch_undef_globs() -- catch "undefined" global variables

gv.b = "abcde"
assert(gv.b == "abcde")

gv.a.x = 7
assert(gv.a.x == 7)

a1 = gv.A()
a1.x = 11
gv.a = a1
assert(gv.a.x == 11)

gv.x = 10
assert(gv.x == 10)

assert(gv.Hi ~= nil)
assert(gv.Hola ~= nil)

gv.h = gv.Hi
assert(gv.h == gv.Hi)


-- It is not clear whether these tests should work or not
-- Currently they don't.
--
-- assert(gv.c_member == 10)
--
-- gv.c_member = 5
-- assert(gv.x == 5)
--
-- gv.h = gv.Hi
-- assert(gv.hr == gv.Hi)
--
-- gv.hr = gv.Hola
-- assert(gv.h == gv.Hola)
-- assert(gv.hr == gv.Hola)
