/* -------------------------------------------------------------------------
 * bindc.swg
 * ------------------------------------------------------------------------- */
/*!
 * \def %fortran_bindc_typedef_struct
 * \brief Wrap a struct as BIND(C).
 *
 * Because SWIG's processing of the feature directive doesn't quite work, if
 * you define a struct as 'typedef struct A {} B;' the features have to apply
 * to A but the typedefs to B.
 *
 * In the typical case that you're wrapping 'struct A {};', then use
 * %fortran_bindc_struct .
 * ------------------------------------------------------------------------- */
%define %fortran_bindc_typedef_struct(CTYPE, TD_CTYPE)
  // Mark the class as being C-bound
  %bindc TD_CTYPE;
  // Bound structs act just like fundamental types
  FORT_FUND_TYPEMAP(CTYPE, "type($fclassname)")

  // Interface code has to "import' the class type.
  %typemap(imtype, import="$fclassname") CTYPE, const CTYPE, const CTYPE&
    "type($fclassname)"
  %typemap(bindc, in="type($fclassname), value", import="$fclassname") CTYPE, const CTYPE, const CTYPE&
    "type($fclassname)"
  %typemap(bindc, in="type($fclassname)", import="$fclassname") CTYPE*, const CTYPE*
    "type(C_PTR)"
%enddef

%define %fortran_bindc_struct(CTYPE)
  %fortran_bindc_typedef_struct(CTYPE, CTYPE)
%enddef

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
