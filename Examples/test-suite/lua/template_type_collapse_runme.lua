require("template_type_collapse")

local i = 1234
local ci = template_type_collapse.DerivedConsterInt()
ci:cccc1(i)
ci:cccc2(i)
ci:cccc3(i)
ci:cccc4(i)

local dci = template_type_collapse.DerivedConsterInt()
dci:dddd(i)
