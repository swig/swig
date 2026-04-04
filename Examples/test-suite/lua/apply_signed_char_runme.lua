local v=require("apply_signed_char")

local smallnum = -127
assert(v.CharValFunction(smallnum) == smallnum)
assert(v.CCharValFunction(smallnum) == smallnum)
assert(v.CCharRefFunction(smallnum) == smallnum)

v.globalchar = smallnum
assert(v.globalchar == smallnum)
assert(v.globalconstchar == -110)

local d = v.DirectorTest()
assert(d:CharValFunction(smallnum) == smallnum)
assert(d:CCharValFunction(smallnum) == smallnum)
assert(d:CCharRefFunction(smallnum) == smallnum)

d.memberchar = smallnum
assert(d.memberchar == smallnum)
assert(d.memberconstchar == -112)
