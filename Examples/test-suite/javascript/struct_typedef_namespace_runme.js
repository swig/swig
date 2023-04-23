var struct_typedef_namespace = require("struct_typedef_namespace");

var b = new struct_typedef_namespace.AffineMatrix();
b.x = b.y = b.z = 1;

if (struct_typedef_namespace.fn1(b) != b.x)
  throw new Error('failed');
