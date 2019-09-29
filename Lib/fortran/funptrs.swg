/* -------------------------------------------------------------------------
 * funptrs.swg
 *
 * Function pointers
 * ------------------------------------------------------------------------- */

%apply void* { SWIGTYPE (*)(ANY) } ;

%typemap(ctype) SWIGTYPE (*)(ANY)
  "$1_ltype"
%typemap(imtype, in="type(C_FUNPTR), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"
%typemap(ftype, in="procedure($*fortranclassname)") SWIGTYPE (*)(ANY)
  "procedure($*fortranclassname), pointer"
%typemap(bindc, in="type(C_FUNPTR), value") SWIGTYPE (*)(ANY)
  "type(C_FUNPTR)"

%typemap(in) SWIGTYPE (*)(ANY) = void *;
%typemap(out) SWIGTYPE (*)(ANY) = void *;

%typemap(fin) SWIGTYPE (*)(ANY)
  "$1 = c_funloc($input)"
%typemap(fout) SWIGTYPE (*)(ANY)
  "call c_f_procpointer($1, $result)"

%apply SWIGTYPE (*)(ANY) { SWIGTYPE (* const)(ANY) } ;

