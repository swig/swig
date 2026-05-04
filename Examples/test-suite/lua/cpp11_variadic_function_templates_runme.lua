local v=require("cpp11_variadic_function_templates")

local ec = v.EmplaceContainer()
ec:emplace(v.A())
ec:emplace(v.A(), v.B())
ec:emplace(v.A(), v.B(), v.C())
ec:emplace(v.A(), v.B(), v.C(), v.D())

function check(expected, got)
    assert(expected == got, "expected: " .. expected .. ", got: " .. got)
end

local a = v.A()
local b = v.B()
local c = v.C()
check(v.variadicmix1(), 20)
check(v.variadicmix1(a), 20)
check(v.variadicmix1(a, b), 10)
check(v.variadicmix1(a, b, c), 20)
check(v.variadicmix1(11, 22), 10)
