var multivalue = require("multivalue");

var [q, r] = multivalue.divide_l(37, 5);
if (q != 7) {
    throw new Error("Test divide_l quotient");
}
if (r != 2) {
    throw new Error("Test divide_l remainder");
}

var [q, r] = multivalue.divide_v(41, 7);
if (q != 5) {
    throw new Error("Test divide_v quotient");
}
if (r != 6) {
    throw new Error("Test divide_v remainder");
}

var [q, r] = multivalue.divide_l(91, 13);
if (q != 7) {
    throw new Error("Test divide_mv quotient");
}
if (r != 0) {
    throw new Error("Test divide_mv remainder");
}
