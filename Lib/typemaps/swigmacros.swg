/* -----------------------------------------------------------------------------
 * SWIG API. Portion only visible from SWIG
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Basic preprocessor macros 
 * ----------------------------------------------------------------------------- */

#define %arg(Arg...) Arg
#define %str(Type...) #Type
#define %block(Block...)  do { Block; } while(0)

/* define a new macro */
%define %define_as(Def, Val...)
%#define Def Val
%enddef

/* include C++ or else value */
%define %ifcplusplus(cppval, nocppval)
#ifdef __cplusplus
cppval
#else
nocppval
#endif
%enddef

/* -----------------------------------------------------------------------------
 * Casting operators
 * ----------------------------------------------------------------------------- */

#ifdef SWIG_NO_CPLUSPLUS_CAST   
/* Disable 'modern' cplusplus casting operators */
# ifdef SWIG_CPLUSPLUS_CAST
#   undef SWIG_CPLUSPLUS_CAST
# endif
#endif

#if defined(__cplusplus) && defined(SWIG_CPLUSPLUS_CAST)
# define %const_cast(a,Type...)       const_cast<Type >(a)
# define %static_cast(a,Type...)      static_cast<Type >(a)
# define %reinterpret_cast(a,Type...) reinterpret_cast<Type >(a)
# define %numeric_cast(a,Type...)     static_cast<Type >(a)
# define %as_voidptr(a)               const_cast<void *>(static_cast<const void *>(a))
# define %as_voidptrptr(a)            reinterpret_cast<void **>(a)
#else /* C case */
# define %const_cast(a,Type...)       (Type)(a)
# define %static_cast(a,Type...)      (Type)(a)
# define %reinterpret_cast(a,Type...) (Type)(a)
# define %numeric_cast(a,Type...)     (Type)(a)
# define %as_voidptr(a)               (void *)(a)
# define %as_voidptrptr(a)            (void **)(a)
#endif /* __cplusplus */

/* -----------------------------------------------------------------------------
 * Allocating/freeing elements 
 * ----------------------------------------------------------------------------- */

#if defined(__cplusplus) 
# define %new_instance(Type...)             (new Type)
# define %new_copy(val,Type...)             (new Type(%static_cast(val, const Type&)))
# define %new_array(size,Type...)           (new Type[size])
# define %new_copy_array(ptr,size,Type...)  %reinterpret_cast(memcpy(%new_array(size,Type), ptr, sizeof(Type)*(size)), Type*)
# define %delete(cptr)                      delete cptr
# define %delete_array(cptr)                delete[] cptr
#else /* C case */
# define %new_instance(Type...)             (Type *)malloc(sizeof(Type))
# define %new_copy(val,Type...)             (Type *)memcpy(%new_instance(Type),&val,sizeof(Type))
# define %new_array(size,Type...)           (Type *)malloc((size)*sizeof(Type))
# define %new_copy_array(ptr,size,Type...)  (Type *)memcpy(%new_array(size,Type), ptr, sizeof(Type)*(size))
# define %delete(cptr)                      free((char*)cptr)
# define %delete_array(cptr)                free((char*)cptr)
#endif /* __cplusplus */

/* -----------------------------------------------------------------------------
 * Swig names and mangling
 * ----------------------------------------------------------------------------- */

#define %mangle(Type...)                  #@Type
#define %name_type(Name, Type...)         SWIG_ ## Name ## _ ## #@Type
#define %string_type(Name, Type...)       "SWIG_" #Name "_" {Type}
#define %checkcode(Code)           	  %name_type(TYPECHECK, Code)



/* 
   Macros to define language dependent object and the void object.
   Use them, for example in Tcl, as
   
     %define_swig_object(Tcl_Obj *)
     %define_void_object(NULL)
*/

/* VOID_Object */
%define %define_void_object(Obj)
#define VOID_Object Obj
%enddef

/* SWIG_Object */
%define %define_swig_object(Obj)
#define SWIG_Object Obj
%enddef

/* -----------------------------------------------------------------------------
 * Auxiliar ugly macros used to write typemaps
 * ----------------------------------------------------------------------------- */


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
#define SWIG_OrderType(Type...)    %name_type(OrderType, Type)
#define SWIG_EqualType(Type...)    %name_type(EqualType, Type)

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
  %_evalif(%arg(_x),%arg(__VA_ARGS__)) 
%enddef

%define %evalif_2(_x,_y,...) 
  %_evalif_2(%arg(_x),%arg(_y),%arg(__VA_ARGS__)) 
%enddef


/* -----------------------------------------------------------------------------
 * Include special macros for fragments
 * ----------------------------------------------------------------------------- */

%include <typemaps/fragmacros.swg>
