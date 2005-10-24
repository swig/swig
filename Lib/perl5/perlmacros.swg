/*
  in Perl we need to pass the CPerl value, sometimes, 
  so, we define  decl/call macros as needed.
*/


#define SWIG_ASPTR_DECL_ARGS SWIG_PERL_DECL_ARGS_2
#define SWIG_ASPTR_CALL_ARGS SWIG_PERL_CALL_ARGS_2

#define SWIG_ASVAL_DECL_ARGS SWIG_PERL_DECL_ARGS_2
#define SWIG_ASVAL_CALL_ARGS SWIG_PERL_CALL_ARGS_2

#define SWIG_FROM_DECL_ARGS  SWIG_PERL_DECL_ARGS_1
#define SWIG_FROM_CALL_ARGS  SWIG_PERL_CALL_ARGS_1

%include <typemaps/swigmacros.swg>

