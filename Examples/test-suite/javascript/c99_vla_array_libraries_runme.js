var c99_vla_array_libraries = require("c99_vla_array_libraries");

function check(a, b) {
  if (a !== b) {
    throw new Error("Not equal: " + a + " " + b);
  }
}

check(6, c99_vla_array_libraries.sum_ints(3, [1, 2, 3]));
check(2, c99_vla_array_libraries.sum_doubles(2, [0.5, 1.5]));

// Only as many elements as the size given at runtime are copied, a shorter array being an error
check(3, c99_vla_array_libraries.sum_ints(2, [1, 2, 3]));
var threw = false;
try {
  c99_vla_array_libraries.sum_ints(4, [1, 2, 3]);
} catch (e) {
  threw = true;
}
if (!threw)
  throw new Error("sum_ints with a shorter array did not throw");

// A negative size is an error
threw = false;
try {
  c99_vla_array_libraries.sum_ints(-1, [1]);
} catch (e) {
  threw = true;
}
if (!threw)
  throw new Error("sum_ints with a negative size did not throw");
