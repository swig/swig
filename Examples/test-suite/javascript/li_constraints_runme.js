var li_constraints = require("li_constraints");

function check_double(except, f, val, name) {
  var actual = true;
  var proper = false;
  try {
    f(val);
  } catch(e) {
    actual = false;
    proper = e.message === "Expected a " + name + " value.";
  }
  if (actual) {
    if (!except)
      throw new Error("function '" + name + "' with " + val + " should perform an exception");
  } else {
    if (except)
      throw new Error("function '" + name + "' with " + val + " should not perform an exception");
    else if (!proper)
      throw new Error("function '" + name + "' with " + val + " should perform a proper exception");
  }
}

const nonnegative = function (val) { li_constraints.test_nonnegative(val); };
check_double(true, nonnegative, 10, "non-negative");
check_double(true, nonnegative, 0, "non-negative");
check_double(false, nonnegative, -10, "non-negative");

const nonpositive = function (val) { li_constraints.test_nonpositive(val); };
check_double(false, nonpositive, 10, "non-positive");
check_double(true, nonpositive, 0, "non-positive");
check_double(true, nonpositive, -10, "non-positive");

const positive = function (val) { li_constraints.test_positive(val); };
check_double(true, positive, 10, "positive");
check_double(false, positive, 0, "positive");
check_double(false, positive, -10, "positive");

const negative = function (val) { li_constraints.test_negative(val); };
check_double(false, negative, 10, "negative");
check_double(false, negative, 0, "negative");
check_double(true, negative, -10, "negative");

const nonzero = function (val) { li_constraints.test_nonzero(val); };
check_double(true, nonzero, 10, "nonzero");
check_double(false, nonzero, 0, "nonzero");
check_double(true, nonzero, -10, "nonzero");

var have_exception = false;
try {
  li_constraints.test_nonnull(null);
} catch(e) {
  have_exception = e.message === "Received a NULL pointer.";
}
if (!have_exception) {
    throw new Error("test_nonnull should perform a proper exception with 'null' value");
}
const nonnull = li_constraints.get_nonnull();
li_constraints.test_nonnull(nonnull);
