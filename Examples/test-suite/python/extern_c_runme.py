import extern_c

extern_c.RealFunction(2)
assert extern_c.cvar.Integer3 == 0
extern_c.cvar.Integer3 = 2
