var typedef_funcptr = require("typedef_funcptr");

var a = 100;
var b = 10;

if (/* await */(typedef_funcptr.do_op(a, b, typedef_funcptr.addf)) != 110) {
  throw new Error("addf failed");
}
if (/* await */(typedef_funcptr.do_op(a, b, typedef_funcptr.subf)) != 90) {
  throw new Error("subf failed");
}

if (/* await */(typedef_funcptr.do_op_typedef_int(a, b, typedef_funcptr.addf)) != 110) {
  throw new Error("addf failed");
}
if (/* await */(typedef_funcptr.do_op_typedef_int(a, b, typedef_funcptr.subf)) != 90) {
  throw new Error("subf failed");
}

if (/* await */(typedef_funcptr.do_op_typedef_Integer(a, b, typedef_funcptr.addf)) != 110) {
  throw new Error("addf failed");
}
if (/* await */(typedef_funcptr.do_op_typedef_Integer(a, b, typedef_funcptr.subf)) != 90) {
  throw new Error("subf failed");
}
