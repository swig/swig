%include <typemaps/swigmacros.swg>


/* aux macros to deal with the interp argument */

#undef SWIG_As_dec
#undef SWIG_AsPtr_dec
#undef SWIG_AsVal_dec

#define SWIG_Tcl_AsVal(Type...) SWIG_Tcl_ ## AsVal ## _ ## #@Type
#define SWIG_AsVal_dec(Type...)  SWIG_ ## AsVal_dec ## _ ## #@Type

#define SWIG_Tcl_AsPtr(Type...) SWIG_Tcl_ ## AsPtr ## _ ## #@Type
#define SWIG_AsPtr_dec(Type...)  SWIG_ ## AsPtr_dec ## _ ## #@Type


%define %tcl_asval_decl(Type...)
%#define SWIG_AsVal_dec(Type)(obj,val) SWIG_Tcl_AsVal(Type)(Tcl_Interp *interp, obj, val)
%#define SWIG_AsVal(Type)(obj,val)     SWIG_Tcl_AsVal(Type)(interp, obj, val)
%enddef


%define %tcl_asptr_decl(Type...)
%#define SWIG_AsPtr_dec(Type)(obj,ptr) SWIG_Tcl_AsPtr(Type)(Tcl_Interp *interp, obj, ptr)
%#define SWIG_AsPtr(Type)(obj,ptr)     SWIG_Tcl_AsPtr(Type)(interp, obj, ptr)
%enddef
