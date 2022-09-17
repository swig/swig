import extern_c

def check(flag):
    if not flag:
        raise RuntimeError("Test failed")

extern_c.RealFunction(2)
check(extern_c.cvar.int2 == 123)
check(extern_c.cvar.int3 == 456)
check(extern_c.cvar.int4 == 789)
