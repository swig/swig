/*
  in Tcl we need to pass the interp value, so, we
  define decl/call macros as needed.
*/

#define SWIG_ASPTR_DECL_ARGS SWIG_TCL_DECL_ARGS_2
#define SWIG_ASPTR_CALL_ARGS SWIG_TCL_CALL_ARGS_2

#define SWIG_ASVAL_DECL_ARGS SWIG_TCL_DECL_ARGS_2
#define SWIG_ASVAL_CALL_ARGS SWIG_TCL_CALL_ARGS_2

%include <typemaps/swigmacros.swg>



