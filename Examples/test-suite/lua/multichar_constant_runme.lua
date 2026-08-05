local v=require("multichar_constant")

-- Multicharacter constants have type int, not char.
assert(v.MULTICHAR_AB == v.imulti_ab, 'MULTICHAR_AB')
