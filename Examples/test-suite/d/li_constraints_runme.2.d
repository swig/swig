module li_constraints_runme;

import std.array;
import std.algorithm;
import std.exception;
import li_constraints.li_constraints;

void check_double(bool except, void function(double) f, double val, string name) {
  bool actual = true;
  bool proper = true;
  try {
    f(val);
  } catch(Exception e) {
    actual = false;
    proper = e.msg.equal(join(["Expected a ", name, " value."]));
  }
  enforce(actual == except);
  enforce(proper);
}
void check_pointer(bool except, void function(void*) f, void* val) {
  bool actual = true;
  bool proper = true;
  try {
    f(val);
  } catch(Exception e) {
    actual = false;
    proper = e.msg.equal("Received a NULL pointer.");
  }
  enforce(actual == except);
  enforce(proper);
}

void main() {
  check_double(true, &test_nonnegative, 10, "non-negative");
  check_double(true, &test_nonnegative, 0, "non-negative");
  check_double(false, &test_nonnegative, -10, "non-negative");

  check_double(false, &test_nonpositive, 10, "non-positive");
  check_double(true, &test_nonpositive, 0, "non-positive");
  check_double(true, &test_nonpositive, -10, "non-positive");

  check_double(true, &test_positive, 10, "positive");
  check_double(false, &test_positive, 0, "positive");
  check_double(false, &test_positive, -10, "positive");

  check_double(false, &test_negative, 10, "negative");
  check_double(false, &test_negative, 0, "negative");
  check_double(true, &test_negative, -10, "negative");

  check_double(true, &test_nonzero, 10, "nonzero");
  check_double(false, &test_nonzero, 0, "nonzero");
  check_double(true, &test_nonzero, -10, "nonzero");

  check_pointer(false, &test_nonnull, null);
  check_pointer(true, &test_nonnull, get_nonnull());
}
