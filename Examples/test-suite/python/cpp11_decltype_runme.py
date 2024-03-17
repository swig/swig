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
