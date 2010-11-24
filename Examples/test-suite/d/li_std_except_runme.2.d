module li_std_except_runme;

import std.exception;
import std.stdio;
import li_std_except.Test;

void main() {
  with (new Test()) {
    enforce(works!(Exception)(&throw_bad_exception));
    enforce(works!(Exception)(&throw_domain_error));
    enforce(works!(Exception)(&throw_exception));
    enforce(works!(Exception)(&throw_invalid_argument));
    enforce(works!(Exception)(&throw_length_error));
    enforce(works!(Exception)(&throw_logic_error));
    enforce(works!(Exception)(&throw_out_of_range));
    enforce(works!(Exception)(&throw_overflow_error));
    enforce(works!(Exception)(&throw_range_error));
    enforce(works!(Exception)(&throw_runtime_error));
    enforce(works!(Exception)(&throw_underflow_error));
  }
}

bool works(alias E, F)(F f) {
  try {
    try {
      f();
    } catch(E) {
      return true;
    }
  } catch(Exception e) {
    writefln( "Received wrong exception: %s", e.classinfo.name );
  }
  return false;
}
