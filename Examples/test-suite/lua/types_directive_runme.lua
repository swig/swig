require("types_directive")

local d1 = types_directive.Time1(2001, 2, 3, 60)
-- check that a Time1 instance is accepted where Date is expected
local newDate = types_directive.add(d1, 7)
assert(newDate.day == 10)

local d2 = types_directive.Time2(1999, 8, 7, 60)
-- check that a Time2 instance is accepted where Date is expected
newDate = types_directive.add(d2, 7)
assert(newDate.day == 14)
