/* -----------------------------------------------------------------------------
 * swigmove.i
 *
 * Input typemaps library for implementing full move semantics when passing
 * parameters by value.
 * ----------------------------------------------------------------------------- */

// Move assignment modifies the proxy classes
%typemap(imtype, in="type(SwigClassWrapper), intent(inout)", fragment="SwigClassWrapper_f") SWIGTYPE MOVE
  "type(SwigClassWrapper)"
%typemap(ftype, in="class($fortranclassname), intent(inout)", nofortransubroutine=1) SWIGTYPE MOVE
  "type($fortranclassname)"

%typemap(in, noblock=1, fragment="SWIG_check_nonnull") SWIGTYPE MOVE ($&1_type argp)  {
  argp = ($&1_ltype)$input->cptr;
  SWIG_check_nonnull(argp, "$1_ltype", "$&fortranclassname", "$decl", return $null);
  SwigValueWrapper< $1_ltype >::reset($1, argp);
}

%typemap(fin, noblock=1) SWIGTYPE MOVE {
  $1 = $input%swigdata
  $input%swigdata%cptr = C_NULL_PTR
}
