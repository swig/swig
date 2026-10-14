%module swig_catch_stdexcept

// SWIG_CATCH_STDEXCEPT without %include <exception.i> or #include <stdexcept>

%exception {
  try {
    $action
  }
  SWIG_CATCH_STDEXCEPT
  catch (...) {
    SWIG_exception(SWIG_UnknownError, "unknown exception");
  }
}

%inline %{
void throw_invalid_argument() {
  throw std::invalid_argument("invalid argument");
}
void throw_out_of_range() {
  throw std::out_of_range("out of range");
}
void throw_runtime_error() {
  throw std::runtime_error("runtime error");
}
void throw_bad_cast() {
  throw std::bad_cast();
}
void throw_exception() {
  throw std::exception();
}
void throw_int() {
  throw 1;
}
%}
