var complextest = require("complextest");

a = [-1,2];

expected = [-1, -2];

a_c = complextest.Conj(a);
if (a_c.toString() != expected.toString())
  throw "Error in Conj(a)";

a_c = complextest.Conjf(a);
if (a_c.toString() != expected.toString())
    throw "Error in Conjf(a)";

a_c = complextest.Conj2(a);
if (a_c.toString() != expected.toString())
  throw "Error in Conj(a)";

a_c = complextest.Conjf2(a);
if (a_c.toString() != expected.toString())
    throw "Error in Conjf(a)";

v = new complextest.VectorStdCplx();
v.add([1,2]);
v.add([2,3]);
v.add([4,3]);
v.add(1);

// TODO: how to check validity?
complextest.CopyHalf(v);
complextest.CopyHalfRef(v);
