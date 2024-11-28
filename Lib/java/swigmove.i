/* -----------------------------------------------------------------------------
 * swigmove.i
 *
 * Input typemaps library for implementing full move semantics when passing
 * parameters by value.
 * ----------------------------------------------------------------------------- */

%typemap(in) SWIGTYPE MOVE ($&1_type argp)
%{ argp = *($&1_ltype*)&$input; 
   if (!argp) {
     SWIG_JavaThrowException(jenv, SWIG_JavaNullPointerException, "Attempt to dereference null $1_type");
     SWIG_fail;
   }
  SwigValueWrapper< $1_ltype >::reset($1, argp); %}

%typemap(javain) SWIGTYPE MOVE "$&javaclassname.swigRelease($javainput)"
