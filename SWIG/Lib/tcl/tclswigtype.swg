%include <typemaps/swigtype.swg>

%typemap(out)    SWIGTYPE    =  SWIGTYPE INSTANCE;
%typemap(out)    SWIGTYPE *  =  SWIGTYPE *INSTANCE;
%typemap(out)    SWIGTYPE &  =  SWIGTYPE &INSTANCE;
%typemap(out)    SWIGTYPE [] =  SWIGTYPE INSTANCE[];
%typemap(varout) SWIGTYPE    =  SWIGTYPE INSTANCE;

%typemap(throws,noblock=1) SWIGTYPE CLASS {
  SWIG_set_result(SWIG_NewInstanceObj(SWIG_as_voidptr(SWIG_new_copy($1, $1_ltype)), $&1_descriptor, 1));
  SWIG_fail;
}

