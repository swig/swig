// This SWIG library file provides language independent exception handling
%include <typemaps/swigmacros.swg>

%insert("runtime") {

  SWIG_define(SWIG_exception(code, msg),        SWIG_block(SWIG_error(code, msg); SWIG_fail))
  SWIG_define(SWIG_contract_assert(expr, msg),  if (!(expr)) { SWIG_error(SWIG_RuntimeError, msg); SWIG_fail; } else)

}
