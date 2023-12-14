var complextest = require("complextest");

a = [-1,2];

expected = [-1, -2];

a_c = /* await */(complextest.Conj(a));
if (a_c.toString() != expected.toString())
  throw "Error in Conj(a)";

a_c = /* await */(complextest.Conjf(a));
if (a_c.toString() != expected.toString())
    throw "Error in Conjf(a)";

a_c = /* await */(complextest.Conj2(a));
if (a_c.toString() != expected.toString())
  throw "Error in Conj(a)";

a_c = /* await */(complextest.Conjf2(a));
if (a_c.toString() != expected.toString())
    throw "Error in Conjf(a)";

v = new /* await */(complextest.VectorStdCplx());
/* await */(v.add([1,2]));
/* await */(v.add([2,3]));
/* await */(v.add([4,3]));
/* await */(v.add(1));

// TODO: how to check validity?
/* await */(complextest.CopyHalf(v));
/* await */(complextest.CopyHalfRef(v));
