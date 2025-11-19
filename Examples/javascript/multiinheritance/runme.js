var example = require("example");

// ----- check inherited enum values -----
console.log("============== D enums ===============");
console.log("D.RED="+example.D.RED+" GREEN="+example.D.GREEN+" BLUE="+example.D.BLUE);

if ((example.D.RED !== example.B.RED) || (example.D.GREEN !== example.B.GREEN) || (example.D.BLUE !== example.B.BLUE)) {
  console.log("Error 'D' enum values should be the same as 'B");
}

console.log("============== E enums ===============");
console.log("E.RED="+example.E.RED+" GREEN="+example.E.GREEN+" BLUE="+example.E.BLUE);

if ((example.E.RED !== example.C.RED) || (example.E.GREEN !== example.C.GREEN) || (example.E.BLUE !== example.C.BLUE)) {
  console.log("Error 'E' enum values should be the same as 'C");
}

// ----- Object creation -----
console.log("============== D instance ===============");
var d = new example.D(1)

console.log("d=" + d);
var proto_d = Object.getPrototypeOf(d);
console.log("proto_d=" + proto_d + " (" + Object.keys(proto_d) + ")");

console.log("(check) " + example.A.count + " created");

console.log("d as b: " + d.b + " (expect 1)");
console.log("d as c: " + d.c + " (expect 1)");

d.b = example.B.BLUE;
d.c = example.C.BLUE;
console.log("d as b: " + d.b + " (expect 0)");
console.log("d as c: " + d.c + " (expect 2)");

// ----- Object cleansing -----
d = null;

console.log("(check) " + example.A.count + " remain");

console.log("Done.");

