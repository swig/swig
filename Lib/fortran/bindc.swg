/* -------------------------------------------------------------------------
 * bindc.swg
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_bindc_typedef_struct
 * \brief Wrap a struct as BIND(C).
 *
 * In the typical case that you're wrapping 'struct A {};', then use
 * %fortran_bindc_struct .
 * ------------------------------------------------------------------------- */
%define %fortran_bindc_struct(CTYPE)
  // Mark the class as being C-bound
  %bindc CTYPE;
  // Bound structs act just like fundamental types
  FORT_FUND_TYPEMAP(CTYPE, "type($fclassname)")

  %fragment("SWIG_null_struct"{CTYPE}, "header",
            fragment="<stdlib.h>") {
CTYPE SWIG_null_struct_ ## CTYPE() {
  CTYPE result;
  memset(&result, sizeof(CTYPE), 0);
  return result;
}
  }

  %typemap(ctype, out="CTYPE", null={SWIG_null_struct_ ## CTYPE()}, fragment="SWIG_null_struct"{CTYPE}) CTYPE
    "const CTYPE*"

  // Interface code has to "import' the class type.
  %typemap(imtype, import="$fclassname") CTYPE, const CTYPE, const CTYPE&
    "type($fclassname)"
  %typemap(bindc, in="type($fclassname), value", import="$fclassname") CTYPE, const CTYPE, const CTYPE&
    "type($fclassname)"
  %typemap(bindc, in="type($fclassname)", import="$fclassname") CTYPE*, const CTYPE*
    "type(C_PTR)"
%enddef

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
