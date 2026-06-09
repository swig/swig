require("virtual_derivation")

local b = virtual_derivation.B(3)
assert(b:get_a() == b:get_b())
