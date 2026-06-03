local v=require("smart_pointer_templatevariables")

local d = v.DiffImContainerPtr_D(v.create(1234, 5678))
assert(d.id == 1234)
d.id = 4321
assert(d.id == 4321)
