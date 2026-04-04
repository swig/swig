require("abstract_typedef2")

local a = abstract_typedef2.A_UF()
assert(a ~= nil)
assert(a:set(0) == nil)
