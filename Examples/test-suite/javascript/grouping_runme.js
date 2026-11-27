var grouping = require("grouping");

var x = grouping.test1(42);
if (x != 42)
    throw new Error;

grouping.test2(42);

var x = grouping.do_unary(37, grouping.NEGATE);
if (x != -37)
    throw new Error;

grouping.test3 = 42;
if (grouping.test3 !== 42)
    throw new Error;

if (grouping.test4(42).value != 42)
    throw new Error;
if (grouping.test5() != 37)
    throw new Error;
if (grouping.test6(42) != 42)
    throw new Error;

var g = new grouping.MemberGrouping();
if (g.method1(42) != 42)
    throw new Error;
if (grouping.MemberGrouping.method2(42) != 42)
    throw new Error;
if (g.method3() != 37)
    throw new Error;
