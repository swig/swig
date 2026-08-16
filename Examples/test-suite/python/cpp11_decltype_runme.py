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

# A function parameter deduces to a function pointer and an array parameter to a pointer to its element,
# so the results can be passed to functions taking those pointer types.
if cpp11_decltype.call_through(cpp11_decltype.function_parameter(cpp11_decltype.cvar.increment_ptr), 4) != 5:
    raise RuntimeError("function_parameter should return a callable function pointer")

if cpp11_decltype.deref_first(cpp11_decltype.array_parameter(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("array_parameter should return an int pointer")

if cpp11_decltype.deref_first(cpp11_decltype.const_array_parameter(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("const_array_parameter should return an int pointer")

if cpp11_decltype.deref_first2(cpp11_decltype.array_parameter_address(cpp11_decltype.three_values())) != 11:
    raise RuntimeError("array_parameter_address should return a pointer to an int pointer")
