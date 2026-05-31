require("virtual_poly")

local d = virtual_poly.NDouble(3.5)
local i = virtual_poly.NInt(2)

-- polymorphic return type working
local dc = d:copy()
local ic = i:copy()

assert(d:get() == dc:get())
assert(i:get() == ic:get())

-- 'narrowing' working ('nnumber' returns a NNumber)
local ddc = virtual_poly.NDouble.narrow(dc:nnumber())
assert(d:get() == ddc:get())

local dic = virtual_poly.NInt.narrow(ic:nnumber())
assert(i:get() == dic:get())
