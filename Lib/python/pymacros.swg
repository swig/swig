%{
/* Auxiliar swig  macros that appear in the header */

#define SWIG_OLDOBJ  1
#define SWIG_NEWOBJ  2

#ifdef __cplusplus
#define SWIGSTATICINLINE(a) static inline a
#define SWIGSTATIC(a) static a
#define swig_new_array(size,Type) (new Type[(size)])
#define swig_delete_array(cptr) delete[] cptr
#define swig_const_cast(a,Type) const_cast<Type >(a)
#define swig_static_cast(a,Type) static_cast<Type >(a)
#define swig_reinterpret_cast(a,Type) reinterpret_cast<Type >(a)
#define swig_new_copy(ptr,Type) (new Type(*ptr))
#define swig_numeric_cast(a,Type) static_cast<Type >(a)

#else /* C case */

#define SWIGSTATICINLINE(a) static a
#define SWIGSTATIC(a) static a
#define swig_new_array(size,Type) ((Type*) malloc((size)*sizeof(Type)))
#define swig_delete_array(cptr) free((char*)cptr)
#define swig_const_cast(a,Type) (Type)(a)
#define swig_static_cast(a,Type) (Type)(a)
#define swig_reinterpret_cast(a,Type) (Type)(a)
#define swig_numeric_cast(a,Type) (Type)(a)
#define swig_new_copy(ptr,Type)  ((Type*)memcpy(malloc(sizeof(Type)),ptr,sizeof(Type)))

#endif /* __cplusplus */
%}


/* Auxiliar swig  macros used to write typemaps */
#define SWIG_arg(...) __VA_ARGS__
#define SWIG_str(...) #__VA_ARGS__

#define SWIG_Mangle(...) #@__VA_ARGS__

#define SWIG_MethodType(Name, ...) SWIG_ ## Name ## _ ## #@__VA_ARGS__
#define SWIG_StringType(Name, ...)  "SWIG_" #Name "_" {__VA_ARGS__}

#define SWIG_AsVal_meth(...)  SWIG_MethodType(AsVal, __VA_ARGS__)
#define SWIG_AsPtr_meth(...)  SWIG_MethodType(AsPtr, __VA_ARGS__)
#define SWIG_As_meth(...)     SWIG_MethodType(As, __VA_ARGS__)
#define SWIG_From_meth(...)   SWIG_MethodType(From, __VA_ARGS__)
#define SWIG_Check_meth(...)  SWIG_MethodType(Check, __VA_ARGS__)
#define SWIG_CCode(...)       SWIG_MethodType(TYPECHECK, __VA_ARGS__)
#define SWIG_OrderType(...)   SWIG_MethodType(OrderType, __VA_ARGS__)
#define SWIG_EqualType(...)   SWIG_MethodType(EqualType, __VA_ARGS__)

#define SWIG_Traits_frag(...)  SWIG_StringType(Traits, __VA_ARGS__)
#define SWIG_AsPtr_frag(...)   SWIG_StringType(AsPtr, __VA_ARGS__)
#define SWIG_AsVal_frag(...)   SWIG_StringType(AsVal, __VA_ARGS__)
#define SWIG_As_frag(...)      SWIG_StringType(As, __VA_ARGS__)
#define SWIG_From_frag(...)    SWIG_StringType(From, __VA_ARGS__)
#define SWIG_Check_frag(...)   SWIG_StringType(Check, __VA_ARGS__)
#define SWIG_CCode_frag(...)   SWIG_StringType(TYPECHECK, __VA_ARGS__)


%define SWIG_define(Def, Val)
%#define Def Val
%enddef

%define SWIG_cplusplus(cppval, cval)
#if __cplusplus
cppval
#else
cval
#endif
%enddef

/* for loop for macro with one argument */

%define %_formacro_1(macro, arg1,...)
macro(arg1)
#if #__VA_ARGS__ != "__fordone__"
%_formacro_1(macro, __VA_ARGS__)
#endif
%enddef

%define %formacro_1(macro,...)
%_formacro_1(macro,__VA_ARGS__,__fordone__)
%enddef

/* for loop for macro with two arguments */

%define %_formacro_2(macro, arg1, arg2, ...)
macro(arg1, arg2)
#if #__VA_ARGS__ != "__fordone__"
%_formacro_2(macro, __VA_ARGS__)
#endif
%enddef

%define %formacro_2(macro,...)
%_formacro_2(macro, __VA_ARGS__, __fordone__)
%enddef


%define %swig_mark_flag(x)
%ignore x;
#define x 1
%enddef

%define %_evalif(x,macro) 
#if x == 1
macro
#endif
%enddef

%define %_evalif_2(x,y,macro) 
#if x == 1 && #y == 1
macro
#endif
%enddef

%define %evalif(x,...) 
  %_evalif(SWIG_arg(x),SWIG_arg(__VA_ARGS__)) 
%enddef

%define %evalif_2(x,y,...) 
  %_evalif_2(SWIG_arg(x),SWIG_arg(y),SWIG_arg(__VA_ARGS__)) 
%enddef

#define %swig_equal_type(...) %swig_mark_flag(SWIG_EqualType(__VA_ARGS__))
#define %swig_order_type(...)		       \
  %swig_mark_flag(SWIG_EqualType(__VA_ARGS__)) \
  %swig_mark_flag(SWIG_OrderType(__VA_ARGS__))
