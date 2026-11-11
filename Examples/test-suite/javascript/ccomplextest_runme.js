var ccomplextest = require("ccomplextest");

if (ccomplextest.has_c99_complex()) {
  let a = [-1,2];
  let expected = [-1, -2];

  let a_c = ccomplextest.Conj(a);
  if (a_c.toString() != expected.toString())
    throw "Error in Conj(a)";

  a_c = ccomplextest.Conjf(a);
  if (a_c.toString() != expected.toString())
      throw "Error in Conjf(a)";

  a_c = ccomplextest.Conj2(a);
  if (a_c.toString() != expected.toString())
    throw "Error in Conj2(a)";

  a_c = ccomplextest.Conjf2(a);
  if (a_c.toString() != expected.toString())
      throw "Error in Conjf2(a)";

  a_c = ccomplextest.Conj3(a);
  if (a_c.toString() != expected.toString())
      throw "Error in Conj3(a)";

  a_c = ccomplextest.Conjf3(a);
  if (a_c.toString() != expected.toString())
      throw "Error in Conjf3(a)";
}
