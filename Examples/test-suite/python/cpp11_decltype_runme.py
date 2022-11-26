import cpp11_decltype

a = cpp11_decltype.A()
a.i = 5
if a.i != 5:
    raise RuntimeError("Assignment to a.i failed.")

a.j = 10
if a.j != 10:
    raise RuntimeError("Assignment to a.j failed.")

b = a.get_number(5)
if b != 10:
    raise RuntimeError("get_number(5) should return 10.")

b = a.get_number(6)
if b != 0:
    raise RuntimeError("get_number(6) should return 0.")
