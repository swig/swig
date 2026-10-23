require("bools")

-- bool constant check
-- TODO: constant should be boolean not number!
assert(bools.constbool ~= true, "constbool")
assert(bools.constbool == 0, "constbool")
-- assert(not bools.constbool, "constbool")

-- bool variables check
assert(bools.bool1, "bool1")
assert(not bools.bool2, "bool2")
assert(bools.value(bools.pbool) == bools.bool1, "bools.pbool")
assert(bools.value(bools.rbool) == bools.bool2, "bools.rbool")
assert(bools.value(bools.const_pbool) == bools.bool1, "const_pbool")
assert(bools.const_rbool == bools.bool2, "const_rbool")

-- bool functions check
assert(not bools.bo(false), "bools.bo(false)")
assert(bools.bo(true), "bools.bo(true)")
assert(bools.value(bools.rbo(bools.rbool)) == bools.value(bools.rbool), "bools.rbo(bools.rbool)")
assert(bools.value(bools.pbo(bools.pbool)) == bools.value(bools.pbool), "bools.pbo(bools.pbool)")
assert(bools.const_rbo(bools.const_rbool) == bools.const_rbool, "const_rbo(bools.const_rbool)")
assert(bools.value(bools.const_pbo(bools.const_pbool)) == bools.value(bools.const_pbool), "bools.const_pbo(bools.const_pbool)")
