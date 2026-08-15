import cpp11_decltype

a = cpp11_decltype.A()
a.i = 5
if a.i != 5:
    raise RuntimeError("Assignment to a.i failed.")

a.j = 10
if a.j != 10:
    raise RuntimeError("Assignment to a.j failed.")

n = a.get_number(5)
if n != 10:
    raise RuntimeError("get_number(5) should return 10.")

n = a.get_number(6)
if n != 0:
    raise RuntimeError("get_number(6) should return 0.")

b = cpp11_decltype.B()

if b.a != False:
    raise RuntimeError("b.a should be False")

if b.b != True:
    raise RuntimeError("b.b should be True")

if b.negate(True) != False:
    raise RuntimeError("b.negate(True) should return False")

if b.negate(False) != True:
    raise RuntimeError("b.negate(False) should return True")

# decltype(&i) deduces 'int *', so the address is returned rather than the function being ignored.
if b.get_number_address(None) is None:
    raise RuntimeError("b.get_number_address should return a pointer")

# A parameter is in scope in the trailing return type, so these return int and float, not Shadowed.
if cpp11_decltype.parameter_shadows_global(5) != 6:
    raise RuntimeError("parameter_shadows_global(5) should return 6")

if cpp11_decltype.parameter_only(1.5) != 2.5:
    raise RuntimeError("parameter_only(1.5) should return 2.5")
