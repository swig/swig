/* -----------------------------------------------------------------------------
 * swigmove.i
 *
 * Input typemaps for move-style Rust ownership transfer.
 * ----------------------------------------------------------------------------- */

%typemap(in, fragment="<memory>") SWIGTYPE MOVE ($&1_type argp) %{
  argp = ($&1_ltype)$input;
  SwigValueWrapper<$1_ltype>::reset($1, argp);
%}

%typemap(rustin) SWIGTYPE MOVE "$rustinput.into_raw()"
