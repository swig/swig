var li_std_vector = require("li_std_vector");

if (li_std_vector.typedef_test(101) != 101) {
  throw new Error;
}

let fail = false;
try {
  sv = new li_std_vector.StructVector();
  sv.add(null);
  fail = true;
} catch { }

if (fail) throw new Error();
