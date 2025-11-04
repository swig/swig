var template_ns = require("template_ns");
var p1 = new template_ns.pairii(2, 3);
var p2 = new template_ns.pairii(p1);

if (p2.first != 2) {
    throw new Error;
}
if (p2.second != 3) {
    throw new Error;
}

var p3 = new template_ns.pairdd(3.5, 2.5);
var p4 = new template_ns.pairdd(p3);

if (p4.first != 3.5) {
    throw new Error;
}

if (p4.second != 2.5) {
    throw new Error;
}
