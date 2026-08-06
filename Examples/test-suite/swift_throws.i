%module swift_throws

// Swift-specific test: a wrapped function that throws a C++ exception is
// surfaced to Swift as a throwing function (see Exceptions handling in the
// Swift backend).

%include <exception.i>

%inline %{
#include <stdexcept>

void might_throw(bool fail) {
  if (fail) {
    throw std::runtime_error("requested failure");
  }
}

int safe_divide(int a, int b) {
  if (b == 0) {
    throw std::out_of_range("division by zero");
  }
  return a / b;
}

%}
