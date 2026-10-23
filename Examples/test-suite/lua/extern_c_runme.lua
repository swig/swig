require("extern_c")

extern_c.RealFunction(2)
assert(extern_c.int2 == 123)
assert(extern_c.int3 == 456)
assert(extern_c.int4 == 789)
