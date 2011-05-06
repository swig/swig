module li_std_except_runme;

import tango.core.Exception;
import tango.io.Console;
import li_std_except.Test;

void main() {
  with (new Test()) {
    mixin(test("Exception", "throw_bad_exception"));
    mixin(test("Exception", "throw_domain_error"));
    mixin(test("Exception", "throw_exception"));
    mixin(test("IllegalArgumentException", "throw_invalid_argument"));
    mixin(test("NoSuchElementException", "throw_length_error"));
    mixin(test("Exception", "throw_logic_error"));
    mixin(test("NoSuchElementException", "throw_out_of_range"));
    mixin(test("Exception", "throw_overflow_error"));
    mixin(test("Exception", "throw_range_error"));
    mixin(test("Exception", "throw_runtime_error"));
    mixin(test("Exception", "throw_underflow_error"));
  }
}

char[] test(char[] e, char[] f) {
  return "if (!works!(" ~ e ~ ")(&" ~ f ~ ")) {\n" ~
    "throw new Exception(\"" ~ f ~ " failed\");\n" ~
  "}";
}

bool works(alias E, F)(F f) {
  try {
    try {
      f();
    } catch(E) {
      return true;
    }
  } catch(Exception e) {
    Cerr( "Received wrong exception: " ~ e.classinfo.name ).newline;
  }
  return false;
}
