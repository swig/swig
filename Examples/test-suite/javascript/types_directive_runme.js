var types_directive = require("types_directive");

d1 = new types_directive.Time1(2001, 2, 3, 60)
// check that a Time1 instance is accepted where Date is expected
newDate = types_directive.add(d1, 7)
if (newDate.day != 10)
    throw new Error("newDate mismatch")

d2 = new types_directive.Time2(1999, 8, 7, 60)
// check that a Time2 instance is accepted where Date is expected
newDate = types_directive.add(d2, 7)
if (newDate.day != 14)
    throw new Error("newDate mismatch")

