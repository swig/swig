%{
/* -----------------------------------------------------------------------------
 * Auxiliar swig  macros that appear in the header 
 * ----------------------------------------------------------------------------- */

/*
  for internal method declarations
*/
#ifdef __cplusplus
#define SWIGSTATICINLINE(a) static inline a
#define SWIGSTATIC(a) static a
#else /* C case */
#define SWIGSTATICINLINE(a) static a
#define SWIGSTATIC(a) static a
#endif /* __cplusplus */

/*
  Alloc. memory flags
*/
#define SWIG_OLDOBJ  1
#define SWIG_NEWOBJ  SWIG_OLDOBJ + 1
#define SWIG_PYSTR   SWIG_NEWOBJ + 1

/*
  swig internal C/C++ API
*/
#ifdef __cplusplus
#define SWIG_new_array(size,Type) (new Type[(size)])
#define SWIG_delete(cptr) delete cptr
#define SWIG_delete_array(cptr) delete[] cptr
#define SWIG_const_cast(a,Type) const_cast<Type >(a)
#define SWIG_static_cast(a,Type) static_cast<Type >(a)
#define SWIG_reinterpret_cast(a,Type) reinterpret_cast<Type >(a)
#define SWIG_new_copy(ptr,Type) (new Type(*ptr))
#define SWIG_numeric_cast(a,Type) static_cast<Type >(a)
#else /* C case */
#define SWIG_new_array(size,Type) ((Type*) malloc((size)*sizeof(Type)))
#define SWIG_delete(cptr) free((char*)cptr)
#define SWIG_delete_array(cptr) free((char*)cptr)
#define SWIG_const_cast(a,Type) (Type)(a)
#define SWIG_static_cast(a,Type) (Type)(a)
#define SWIG_reinterpret_cast(a,Type) (Type)(a)
#define SWIG_numeric_cast(a,Type) (Type)(a)
#define SWIG_new_copy(ptr,Type)  ((Type*)memcpy(malloc(sizeof(Type)),ptr,sizeof(Type)))
#endif /* __cplusplus */

/*
  Exception handling in wrappers
*/
#define SWIG_fail                goto fail
#define SWIG_arg_fail(arg)       SWIG_Python_ArgFail(arg)
#define SWIG_append_errmsg(msg)   SWIG_Python_AddErrMesg(msg,0)
#define SWIG_preppend_errmsg(msg) SWIG_Python_AddErrMesg(msg,1)
#define SWIG_type_error(type,obj) SWIG_Python_TypeError(type,obj)
#define SWIG_null_ref(type)       SWIG_Python_NullRef(type)

/*
  Contract support
*/
#define SWIG_contract_assert(expr, msg) \
 if (!(expr)) { PyErr_SetString(PyExc_RuntimeError, (char *) msg ); goto fail; } else

%}

/* -----------------------------------------------------------------------------
 * Auxiliar swig  macros used to write typemaps
 * ----------------------------------------------------------------------------- */

#define SWIG_arg(...) __VA_ARGS__
#define SWIG_str(...) #__VA_ARGS__

#define SWIG_Mangle(...) #@__VA_ARGS__
#define SWIG_Descriptor(...) SWIGTYPE_ ## #@__VA_ARGS__

#define SWIG_NameType(Name, ...) SWIG_ ## Name ## _ ## #@__VA_ARGS__
#define SWIG_StringType(Name, ...)  "SWIG_" #Name "_" {__VA_ARGS__}

#define SWIG_AsVal(...)  SWIG_NameType(AsVal, __VA_ARGS__)
#define SWIG_AsPtr(...)  SWIG_NameType(AsPtr, __VA_ARGS__)
#define SWIG_As(...)     SWIG_NameType(As, __VA_ARGS__)
#define SWIG_From(...)   SWIG_NameType(From, __VA_ARGS__)
#define SWIG_Check(...)  SWIG_NameType(Check, __VA_ARGS__)
#define SWIG_CCode(...)       SWIG_NameType(TYPECHECK, __VA_ARGS__)
#define SWIG_OrderType(...)   SWIG_NameType(OrderType, __VA_ARGS__)
#define SWIG_EqualType(...)   SWIG_NameType(EqualType, __VA_ARGS__)

#define SWIG_Traits_frag(...)  SWIG_StringType(Traits, __VA_ARGS__)
#define SWIG_AsPtr_frag(...)   SWIG_StringType(AsPtr, __VA_ARGS__)
#define SWIG_AsVal_frag(...)   SWIG_StringType(AsVal, __VA_ARGS__)
#define SWIG_As_frag(...)      SWIG_StringType(As, __VA_ARGS__)
#define SWIG_From_frag(...)    SWIG_StringType(From, __VA_ARGS__)
#define SWIG_Check_frag(...)   SWIG_StringType(Check, __VA_ARGS__)
#define SWIG_CCode_frag(...)   SWIG_StringType(TYPECHECK, __VA_ARGS__)


/* define a new macro */
%define SWIG_define(Def, Val)
%#define Def Val
%enddef

/* include C++ or C value */
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

/* for loop for macro with one argument */
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

/* for loop for macro with two arguments */
%define %formacro_2(macro,...)
%_formacro_2(macro, __VA_ARGS__, __fordone__)
%enddef


/* 
  mark a flag, ie, define a macro name but ignore it in
  the interface. 
  
  the flags latter can be used with %evalif
*/

%define %swig_mark_flag(x)
%ignore x;
#define x 1
%enddef

/*
 %swig_equal_type and %swig_order_type flagged a type of having equal (==,!=)
 and/or order methods  (<=,>=,<,>).
*/
#define %swig_equal_type(...) %swig_mark_flag(SWIG_EqualType(__VA_ARGS__))
#define %swig_order_type(...)		       \
  %swig_mark_flag(SWIG_EqualType(__VA_ARGS__)) \
  %swig_mark_flag(SWIG_OrderType(__VA_ARGS__))

/*
  %evalif and %evalif_2 are use to evaluate or process 
  an expression if the given predicate is 'true' (1).
*/
%define %_evalif(_x,_expr) 
#if _x == 1
_expr
#endif
%enddef

%define %_evalif_2(_x,_y,_expr) 
#if _x == 1 && _y == 1
_expr
#endif
%enddef

%define %evalif(_x,...) 
  %_evalif(SWIG_arg(_x),SWIG_arg(__VA_ARGS__)) 
%enddef

%define %evalif_2(_x,_y,...) 
  %_evalif_2(SWIG_arg(_x),SWIG_arg(_y),SWIG_arg(__VA_ARGS__)) 
%enddef


