require("import")	-- the import fn
import("overload_null")	-- import lib into global

o = overload_null.Overload()
x = overload_null.X()

assert(1 == o:byval1(x))
assert(2 == o:byval1(nil))

assert(3 == o:byval2(nil))
assert(4 == o:byval2(x))

assert(5 == o:byref1(x))
assert(6 == o:byref1(nil))

assert(7 == o:byref2(nil))
assert(8 == o:byref2(x))

assert(9 == o:byconstref1(x))
assert(10 == o:byconstref1(nil))

assert(11 == o:byconstref2(nil))
assert(12 == o:byconstref2(x))

-- const pointer references
assert(13 == o:byval1cpr(x))
assert(14 == o:byval1cpr(nil))

assert(15 == o:byval2cpr(nil))
assert(16 == o:byval2cpr(x))

-- fwd class declaration
assert(17 == o:byval1fwdptr(x))
assert(18 == o:byval1fwdptr(nil))

assert(19 == o:byval2fwdptr(nil))
assert(20 == o:byval2fwdptr(x))

assert(21 == o:byval1fwdref(x))

assert(22 == o:byval2fwdref(x))
