var types_directive_nspace = require("types_directive_nspace");

var d1 = new types_directive_nspace.time1.Time1(2001, 2, 3, 60)
// check that a Time1 instance is accepted where Date is expected
var newDate = /* await */(types_directive_nspace.add(d1, 7))
if (newDate.day != 10)
    throw new Error("newDate mismatch")

var d2 = new types_directive_nspace.time2.Time2(1999, 8, 7, 60)
// check that a Time2 instance is accepted where Date is expected
newDate = /* await */(types_directive_nspace.add(d2, 7))
if (newDate.day != 14)
    throw new Error("newDate mismatch")

