from implicittest import *

def check(a, b):
    if a != b:
        raise RuntimeError(str(a) + " does not equal " + str(b))

#### Class ####

# No implicit conversion
check(1, A(1).get())
check(2, A(1.0).get())
check(3, A(B()).get())
check(4, A("hello").get())

check(1, get(1))
check(2, get(1.0))
check(3, get(B()))

# Explicit constructor:
try:
    check(4, get("hello"))
    raise RuntimeError
except TypeError:
    pass

#### Template Class ####

# No implicit conversion
check(1, A_int(1).get())
check(2, A_int(1.0).get())
check(3, A_int(B()).get())
check(4, A_int("hello").get())

check(1, A_int.sget(1))
check(2, A_int.sget(1.0))
check(3, A_int.sget(B()))

# explicit constructor:
try:
    check(4, A_int.sget("hello"))
    raise RuntimeError
except TypeError:
    pass

#### Global variable assignment ####

cvar.foo = Foo(1);          check(cvar.foo.ii, 1)
cvar.foo = 1;               check(cvar.foo.ii, 1)
cvar.foo = 1.0;             check(cvar.foo.ii, 2)
cvar.foo = Foo("hello");    check(cvar.foo.ii, 3)

# explicit constructor:
try:
    cvar.foo = "hello"
    raise RuntimeError
except TypeError:
    pass

#### Member variable assignment ####
# Note: also needs naturalvar

b = Bar();                  check(b.f.ii, 0)
b.f = Foo("hello");         check(b.f.ii, 3)
b.f = 1;                    check(b.f.ii, 1)
b.f = 1.0;                  check(b.f.ii, 2)

# explicit constructor:
try:
    b.f = "hello"
    raise RuntimeError
except TypeError:
    pass

