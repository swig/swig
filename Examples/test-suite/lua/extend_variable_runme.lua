require("import")
require("extend_variable")
ev=extend_variable
catch_undef_globs() -- catch "undefined" global variables

e1 = ev.ExtendMe()
answ = 1.0
assert(e1:set(7.0))
--assert(e1:get(answ)) -- doesn't work. Lua can't pass primitive type by non-const reference
--assert(answ == 7.0)

e1.ExtendVar = 5.0
assert(e1.ExtendVar == 5.0)

assert(ev.Foo.Bar == 42)
assert(ev.Foo.AllBarOne == 4422)

assert(ev.Foo.StaticInt == 1111)
ev.Foo.StaticInt = 3333
assert(ev.Foo.StaticInt == 3333)

assert(ev.Foo.StaticConstInt == 2222)

b1 = ev.Bar()
assert(b1.x == 1)
