require("template_type_collapse")

local i = 1234
local ci = template_type_collapse.DerivedConsterInt()
ci:cccc1(i)
ci:cccc2(i)
ci:cccc3(i)
ci:cccc4(i)

local dci = template_type_collapse.DerivedConsterInt()
dci:dddd(i)

assert(template_type_collapse.VolatilerConstInt():take_const(i) == i)
assert(template_type_collapse.VolatilerConstInt():take_volatile() == 42)
assert(template_type_collapse.VolatilerVolatileInt():take_const() == 42)
assert(template_type_collapse.VolatilerConstVolatileInt():take_const() == 42)
assert(template_type_collapse.VolatilerConstVolatileInt():take_volatile() == 42)

assert(template_type_collapse.ArrayerInt3():take_const() == 42)
assert(template_type_collapse.ArrayerConstInt3():take_const() == 42)
assert(template_type_collapse.ArrayerVolatileInt3():take_const() == 43)
