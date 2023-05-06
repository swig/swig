var cpp11_using_typedef_struct = require("cpp11_using_typedef_struct");

var b = new cpp11_using_typedef_struct.AffineMatrix();
b.x = b.y = b.z = 1;

if (cpp11_using_typedef_struct.fn1(b) != b.x)
  throw new Error('failed');

var bb = new cpp11_using_typedef_struct.xCacheView();
bb.x = 123;

if (cpp11_using_typedef_struct.fn2(bb) != 123)
  throw new Error('failed');
