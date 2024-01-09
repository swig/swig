var voidtest = require("voidtest");

/* await */(voidtest.globalfunc());
var f = new voidtest.Foo();
/* await */(f.memberfunc());

/* await */(voidtest.Foo.staticmemberfunc());

if (/* await */(f.memberfunc()) !== (function(){}())) {
  throw new Error("f.memberfunc() didn't return same result as pure Javascript equivalent");
}

var v1 = /* await */(voidtest.vfunc1(f));
var v2 = /* await */(voidtest.vfunc2(f));
if (!/* await */(voidtest.test_pointers_equal(v1, v2))) {
  throw new Error("!voidtest.test_pointers_equal(v1, v2)");
}

var v3 = /* await */(voidtest.vfunc3(v1));
if (!/* await */(voidtest.test_pointers_equal(/* await */(v3.get_this()), /* await */(f.get_this())))) {
  throw new Error("!voidtest.test_pointers_equal(v3.get_this(), f.get_this())");
}
var v4 = /* await */(voidtest.vfunc1(f));
if (!/* await */(voidtest.test_pointers_equal(v4, v1))) {
  throw new Error("!voidtest.test_pointers_equal(v4, v1)");
}

/* await */(v3.memberfunc());
