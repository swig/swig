import extern_c

extern_c.RealFunction(2)
assert extern_c.cvar.int2 == 123
assert extern_c.cvar.int3 == 456
assert extern_c.cvar.int4 == 789
