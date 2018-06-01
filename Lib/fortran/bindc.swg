/* -------------------------------------------------------------------------
 * bindc.swg
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortranbindc_type
 * \brief Wrap a struct as BIND(C).
 *
 * In the typical case that you're wrapping 'struct A {};', then use
 * %fortranbindc_type .
 * ------------------------------------------------------------------------- */
%define %fortranbindc_type(CTYPE)
  // Mark the class as being C-bound
  %fortranbindc CTYPE;
  // Bound structs act just like fundamental types
  FORT_FUND_TYPEMAP(CTYPE, "type($fclassname)")

  %fragment("SWIG_null_struct"{CTYPE}, "header",
            fragment="<string.h>") {
CTYPE SWIG_null_struct_ ## CTYPE() {
  CTYPE result;
  memset(&result, sizeof(CTYPE), 0);
  return result;
}
  }

  %typemap(ctype, out="CTYPE", null={SWIG_null_struct_ ## CTYPE()}, fragment="SWIG_null_struct"{CTYPE}) CTYPE, const CTYPE&
    "const CTYPE*"

  // Interface code has to "import' the class type.
  %typemap(imtype, import="$fclassname") CTYPE, const CTYPE, const CTYPE&
    "type($fclassname)"
  %typemap(bindc, in="type($fclassname), value", import="$fclassname") CTYPE, const CTYPE, const CTYPE&
    "type($fclassname)"
  %typemap(bindc, in="type($fclassname)", import="$fclassname") CTYPE*, const CTYPE*
    "type(C_PTR)"
%enddef


