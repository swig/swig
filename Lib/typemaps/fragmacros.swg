/* 
   Special macros to define and use fragment names and declarations.

   These macros generate the names used in fragments, for example, a
   typical use will be:

      %fragment(SWIG_From_frag(bool),"header") {     
      SWIGINTERNINLINE PyObject*		       
      SWIG_From_dec(bool)(bool value)	       
      {					       
        PyObject *obj = value ? Py_True : Py_False;  
        Py_INCREF(obj);			       
        return obj;				       
      }					       
      }					       
      					 
   and then you can call the method using

      %typemap(out,fragment=SWIG_From_frag(bool)) bool {
         %set_output(SWIG_From(bool)($1));
      }

   when the typemap get generated, the proper fragment for the
   SWIG_From(bool) method will be included.
      
 */


													 
#define SWIG_Traits_frag(Type...)  	%string_type(Traits, Type) 
#define SWIG_AsPtr_frag(Type...)   	%string_type(AsPtr, Type)	 
#define SWIG_AsVal_frag(Type...)   	%string_type(AsVal, Type)	 
#define SWIG_From_frag(Type...)    	%string_type(From, Type)	 


#ifndef SWIG_ASVAL_DECL_ARGS
#define SWIG_ASVAL_DECL_ARGS
#endif

#ifndef SWIG_ASPTR_DECL_ARGS
#define SWIG_ASPTR_DECL_ARGS
#endif

#ifndef SWIG_FROM_DECL_ARGS
#define SWIG_FROM_DECL_ARGS
#endif

#ifndef SWIG_ASVAL_CALL_ARGS
#define SWIG_ASVAL_CALL_ARGS
#endif

#ifndef SWIG_ASPTR_CALL_ARGS
#define SWIG_ASPTR_CALL_ARGS
#endif

#ifndef SWIG_FROM_CALL_ARGS
#define SWIG_FROM_CALL_ARGS
#endif


#define SWIG_AsVal_dec(Type...)   %name_type(AsVal, Type) SWIG_ASVAL_DECL_ARGS
#define SWIG_AsPtr_dec(Type...)   %name_type(AsPtr, Type) SWIG_ASPTR_DECL_ARGS
#define SWIG_From_dec(Type...)    %name_type(From, Type)  SWIG_FROM_DECL_ARGS 

#define SWIG_AsVal(Type...)       %name_type(AsVal, Type) SWIG_ASVAL_CALL_ARGS 
#define SWIG_AsPtr(Type...)  	  %name_type(AsPtr, Type) SWIG_ASPTR_CALL_ARGS 	 
#define SWIG_From(Type...)   	  %name_type(From, Type)  SWIG_FROM_CALL_ARGS 




/* ------------------------------------------------------------
 * common macro helpers
 * ------------------------------------------------------------ */


/* Macros for numeric types */

%define %numeric_type_from(Type, Base)
%fragment(SWIG_From_frag(Type),"header",
	  fragment=SWIG_From_frag(Base)) {
SWIGINTERNINLINE SWIG_Object
SWIG_From_dec(Type)(Type value)
{    
  return SWIG_From(Base)(value);
}
}
%enddef

%define %numeric_type_asval(Type, Base, Frag, OverflowCond)
%fragment(SWIG_AsVal_frag(Type),"header",
	  fragment=Frag,
	  fragment=SWIG_AsVal_frag(Base)) {
SWIGINTERN int
SWIG_AsVal_dec(Type)(SWIG_Object obj, Type *val)
{
  Base v;
  int res = SWIG_AsVal(Base)(obj, &v);
  if (res == SWIG_OK) {
    if (OverflowCond) {
      return SWIG_OverflowError;
    } else {
      if (val) *val = %numeric_cast(v, Type);
      return SWIG_OK;
    }
  }  
  return res;
}
}
%enddef

%define %numeric_signed_type_asval(Type, Base, Frag, Min, Max)
%numeric_type_asval(Type, Base, Frag, (v < Min || v > Max))
%enddef

%define %numeric_unsigned_type_asval(Type, Base, Frag, Max)
%numeric_type_asval(Type, Base, Frag, (v > Max))
%enddef


/* Macro for 'signed long' derived types */

%define %numeric_slong(Type, Frag, Min, Max)
%numeric_type_from(Type, long)
%numeric_signed_type_asval(Type, long, Frag , Min, Max)
%enddef

/* Macro for 'unsigned long' derived types */

%define %numeric_ulong(Type, Frag, Max)
%numeric_type_from(Type, unsigned long)
%numeric_unsigned_type_asval(Type, unsigned long, Frag, Max)
%enddef


/* Macro for 'double' derived types */

%define %numeric_double(Type, Frag, Min, Max)
%numeric_type_from(Type, double)
%numeric_signed_type_asval(Type, double, Frag , Min, Max)
%enddef


