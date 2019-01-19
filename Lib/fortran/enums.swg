/* -------------------------------------------------------------------------
 * enums.swg
 * ------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------
 * ENUMS
 * ------------------------------------------------------------------------- */

// Most of the opertions are like integers, but replace the fortran wrapper
// with the kind of enum. Don't worry about pointer types (leave those as
// integer pointers)
FORT_UNSIGNED_TYPEMAP(int, enum SWIGTYPE)

%typemap(ftype, in="integer($fenumname), intent(in)") enum SWIGTYPE
  "integer($fenumname)"
%typemap(out, noblock=1) enum SWIGTYPE {
  $result = %static_cast($1, int);
}

%typemap(imtype) const enum SWIGTYPE& = enum SWIGTYPE;
%typemap(ftype)  const enum SWIGTYPE& = enum SWIGTYPE;
%typemap(fin)    const enum SWIGTYPE& = enum SWIGTYPE;
%typemap(fout)   const enum SWIGTYPE& = enum SWIGTYPE;
