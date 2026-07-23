local v=require("apply_signed_char")

-- The test require char to be signed
-- Skip the test if char is unsigned
if v.is_char_signed() == 0 then
  os.exit()
end

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
