/* -------------------------------------------------------------------------
 * enums.swg
 * ------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------
 * ENUMS
 * ------------------------------------------------------------------------- */

// Most of the opertions are like integers, but replace the fortran wrapper
// with the kind of enum. Don't worry about pointer types (leave those as
// integer pointers)
%fortran_unsigned(int, enum SWIGTYPE)

%typemap(ftype, in="integer($fortranclassname), intent(in)") enum SWIGTYPE
  "integer($fortranclassname)"
%typemap(out, noblock=1) enum SWIGTYPE {
  $result = (int)($1);
}
%typemap(out, noblock=1) const enum SWIGTYPE& {
  $result = (int)(*$1);
}

%typemap(ftype, in="integer($*fortranclassname), intent(in)") const enum SWIGTYPE&
  "integer($*fortranclassname)"
%typemap(imtype) const enum SWIGTYPE& = enum SWIGTYPE;
%typemap(fin)    const enum SWIGTYPE& = enum SWIGTYPE;
%typemap(fout)   const enum SWIGTYPE& = enum SWIGTYPE;
