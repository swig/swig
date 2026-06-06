var voidtest = require("voidtest");

voidtest.globalfunc();
var f = new voidtest.Foo();
f.memberfunc();

voidtest.Foo.staticmemberfunc();

if (f.memberfunc() !== (function(){}())) {
  throw new Error("f.memberfunc() didn't return same result as pure Javascript equivalent");
}

v1 = voidtest.vfunc1(f);
v2 = voidtest.vfunc2(f);
if (!voidtest.test_pointers_equal(v1, v2)) {
  throw new Error("!voidtest.test_pointers_equal(v1, v2)");
}

v3 = voidtest.vfunc3(v1);
if (!voidtest.test_pointers_equal(v3.get_this(), f.get_this())) {
  throw new Error("!voidtest.test_pointers_equal(v3.get_this(), f.get_this())");
}
v4 = voidtest.vfunc1(f);
if (!voidtest.test_pointers_equal(v4, v1)) {
  throw new Error("!voidtest.test_pointers_equal(v4, v1)");
}

v3.memberfunc();
