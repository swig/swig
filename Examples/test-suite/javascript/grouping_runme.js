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
