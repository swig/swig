var typedef_funcptr = require("typedef_funcptr");

a = 100;
b = 10;

if (typedef_funcptr.do_op(a, b, typedef_funcptr.addf) != 110) {
  throw new Error("addf failed");
}
if (typedef_funcptr.do_op(a, b, typedef_funcptr.subf) != 90) {
  throw new Error("subf failed");
}

if (typedef_funcptr.do_op_typedef_int(a, b, typedef_funcptr.addf) != 110) {
  throw new Error("addf failed");
}
if (typedef_funcptr.do_op_typedef_int(a, b, typedef_funcptr.subf) != 90) {
  throw new Error("subf failed");
}

if (typedef_funcptr.do_op_typedef_Integer(a, b, typedef_funcptr.addf) != 110) {
  throw new Error("addf failed");
}
if (typedef_funcptr.do_op_typedef_Integer(a, b, typedef_funcptr.subf) != 90) {
  throw new Error("subf failed");
}
