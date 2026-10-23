local v=require("cpp11_ref_qualifiers")

-- Basic testing
local h = v.Host()
h:h1()
h:h2()
h:h6()
h:h7()
h:h()

-- %feature testing
local f = v.Features()
assert(f:F1() == "F1")
assert(f:F2() == "F2")
assert(f:F3() == "F3")
assert(f:C1(0) == "C1")
assert(f:C2(0) == "C2")
assert(f:C3(0) == "C3")

-- %rename testing
local r = v.Renames()
r:RR1()
r:RR2()
r:RR3()
r:SS1(0)
r:SS2(0)
r:SS3(0)

-- Conversion operators
local co = v.ConversionOperators()
local s = co:StringConvertCopy()
s = co:StringConvertMove()

local co2 = v.ConversionOperators2()
s = co2:StringConvertMove()
