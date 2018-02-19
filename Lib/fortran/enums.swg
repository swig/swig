/* -------------------------------------------------------------------------
 * enums.swg
 * ------------------------------------------------------------------------- */

%fragment("SwigUnknownEnum_f", "fpublic", noblock=1) %{
enum, bind(c)
  enumerator :: SwigUnknownEnum = -1
end enum
%}

/* -------------------------------------------------------------------------
 * ENUMS
 * ------------------------------------------------------------------------- */

// Most of the opertions are like integers, but replace the fortran wrapper
// with the kind of enum. Don't worry about pointer types (leave those as
// integer pointers)
FORT_SIMPLE_TYPEMAP(enum SWIGTYPE, int, "integer(C_INT)");

// Fortran input types look like enums
%typemap(in, noblock=1) enum SWIGTYPE {
  $1 = %static_cast(*$input, $1_ltype);
}
%typemap(out, noblock=1) enum SWIGTYPE {
  $result = %static_cast($1, int);
}
%typemap(ftype, out="integer(kind($fenumname))") enum SWIGTYPE
  "integer(kind($fenumname)), intent(in)"

%typemap(in, noblock=1) const enum SWIGTYPE& ($*1_ltype temp) {
  temp = %static_cast(*$input, $*1_ltype);
  $1 = &temp;
}
%typemap(out, noblock=1) const enum SWIGTYPE& {
  $result = %static_cast(*$1, int);
}
%typemap(ftype) const enum SWIGTYPE& = enum SWIGTYPE;

#if 0
// NOTE: GCC generates lots of warnings when you try to bind to an enum type,
// even if that enum is C-bound. Instead, just use integer bindings.
%typemap(bindc, in="integer(kind($fenumname)), value") enum SWIGTYPE
  "integer(kind($fenumname))"
%typemap(bindc, in="integer(kind($fenumname))") enum SWIGTYPE*
  "type(C_PTR)"
#else
%typemap(bindc, in="integer(C_INT), value") enum SWIGTYPE
  "integer(C_INT)"
%typemap(bindc, in="integer(C_INT)") enum SWIGTYPE*
  "type(C_PTR)"
#endif


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
