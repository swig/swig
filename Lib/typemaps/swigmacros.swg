/* -----------------------------------------------------------------------------
 * SWIG API. Portion only visible from SWIG
 * ----------------------------------------------------------------------------- */

/* basic preprocessor macros */

#define SWIG_arg(Arg...) Arg
#define SWIG_str(Type...) #Type
#define SWIG_block(Block...)  do { Block; } while(0)

/* casting operators */

#ifdef SWIG_NO_CPLUSPLUS_CAST   
/* Disable 'modern' cplusplus casting operators */
# ifdef SWIG_CPLUSPLUS_CAST
#   undef SWIG_CPLUSPLUS_CAST
# endif
#endif

#if defined(__cplusplus) && defined(SWIG_CPLUSPLUS_CAST)
# define SWIG_const_cast(a,Type...)       const_cast<Type >(a)
# define SWIG_static_cast(a,Type...)      static_cast<Type >(a)
# define SWIG_reinterpret_cast(a,Type...) reinterpret_cast<Type >(a)
# define SWIG_numeric_cast(a,Type...)     static_cast<Type >(a)
# define SWIG_as_voidptr(a)               const_cast<void *>(static_cast<const void *>(a))
# define SWIG_as_voidptrptr(a)            reinterpret_cast<void **>(a)
#else /* C case */
# define SWIG_const_cast(a,Type...)       (Type)(a)
# define SWIG_static_cast(a,Type...)      (Type)(a)
# define SWIG_reinterpret_cast(a,Type...) (Type)(a)
# define SWIG_numeric_cast(a,Type...)     (Type)(a)
# define SWIG_as_voidptr(a)               (void *)(a)
# define SWIG_as_voidptrptr(a)            (void **)(a)
#endif /* __cplusplus */

/* macros for allocating/freeing elements */

#if defined(__cplusplus) 
# define SWIG_new(Type...)                      (new Type)
# define SWIG_new_copy(val,Type...)             (new Type(val))
# define SWIG_new_array(size,Type...)           (new Type[size])
# define SWIG_new_copy_array(ptr,size,Type...)  SWIG_reinterpret_cast(memcpy(SWIG_new_array(size,Type), ptr, sizeof(Type)*(size)), Type*)
# define SWIG_delete(cptr)                      delete cptr
# define SWIG_delete_array(cptr)                delete[] cptr
#else /* C case */
# define SWIG_new(Type...)                      (Type *)malloc(sizeof(Type))
# define SWIG_new_copy(val,Type...)             (Type *)memcpy(SWIG_new(Type),&val,sizeof(Type))
# define SWIG_new_array(size,Type...)           (Type *)malloc((size)*sizeof(Type))
# define SWIG_new_copy_array(ptr,size,Type...)  (Type *)memcpy(SWIG_new_array(size,Type), ptr, sizeof(Type)*(size))
# define SWIG_delete(cptr)                      free((char*)cptr)
# define SWIG_delete_array(cptr)                free((char*)cptr)
#endif /* __cplusplus */

/* macros for fragments/typemaps */

#define SWIG_Mangle(Type...)            #@Type
#define SWIG_Descriptor(Type...)        SWIGTYPE_ ## #@Type
#define SWIG_NameType(Name, Type...)    SWIG_ ## Name ## _ ## #@Type
#define SWIG_StringType(Name, Type...) "SWIG_" #Name "_" {Type}

#define SWIG_AsVal(Type...)        SWIG_NameType(AsVal, Type) 
#define SWIG_AsPtr(Type...)  	   SWIG_NameType(AsPtr, Type)
#define SWIG_As(Type...)     	   SWIG_NameType(As, Type)   
#define SWIG_From(Type...)   	   SWIG_NameType(From, Type) 
#define SWIG_Check(Type...)  	   SWIG_NameType(Check, Type)
#define SWIG_OrderType(Type...)    SWIG_NameType(OrderType, Type)
#define SWIG_EqualType(Type...)    SWIG_NameType(EqualType, Type)

#define SWIG_AsVal_dec(Type...)    SWIG_NameType(AsVal, Type) 
#define SWIG_AsPtr_dec(Type...)    SWIG_NameType(AsPtr, Type)
#define SWIG_As_dec(Type...)       SWIG_NameType(As, Type)   
#define SWIG_From_dec(Type...)     SWIG_NameType(From, Type) 
#define SWIG_Check_dec(Type...)    SWIG_NameType(Check, Type)

#define SWIG_Traits_frag(Type...)  SWIG_StringType(Traits, Type)
#define SWIG_AsPtr_frag(Type...)   SWIG_StringType(AsPtr, Type)
#define SWIG_AsVal_frag(Type...)   SWIG_StringType(AsVal, Type)
#define SWIG_As_frag(Type...)      SWIG_StringType(As, Type)
#define SWIG_From_frag(Type...)    SWIG_StringType(From, Type)
#define SWIG_Check_frag(Type...)   SWIG_StringType(Check, Type)

#define SWIG_CCode(Type...)        SWIG_NameType(TYPECHECK, Type)
#define SWIG_CCode_frag(Type...)   SWIG_StringType(TYPECHECK, Type)


/* macros for result manipulation */

#define SWIG_set_result(obj)          SWIG_SetResultObj(obj) 
#define SWIG_append_result(obj)       SWIG_AppendResultObj(obj) 
#define SWIG_set_constant(n, v)       SWIG_SetConstantObj(n,v)

/* macros for error manipulation */
#define SWIG_TypeErrorFmt(_type,_name)   "expected '"_type"'"
#define SWIG_VarFailFmt(_type,_name)     "in variable '"_name"' of type '"_type"'"
#define SWIG_ArgFailFmt(_type,_argn)     "in argument " #_argn" of type '" _type"'"
#define SWIG_OutFailFmt(_type)           "in output of type '"_type"'"
#define SWIG_ArgNullRefFmt(_type, _argn) "null reference " SWIG_ArgFailFmt(_type, _argn)
#define SWIG_VarNullRefFmt(_type, _name) "null reference " SWIG_VarFailFmt(_type, _name)
#define SWIG_OutNullRefFmt(_type)        "null reference " SWIG_OutFailFmt(_type)

#define SWIG_ArgFail(code,type,argn)  SWIG_SetErrorMsg(code,SWIG_ArgFailFmt(type, argn))
#define SWIG_VarFail(code,type,name)  SWIG_SetErrorMsg(code,SWIG_VarFailFmt(type, name))
#define SWIG_ArgNullRef(type,argn)    SWIG_SetErrorMsg(SWIG_ValueError, SWIG_ArgNullRefFmt(type, argn))
#define SWIG_VarNullRef(type,name)    SWIG_SetErrorMsg(SWIG_ValueError, SWIG_VarNullRefFmt(type, name))
#define SWIG_OutNullRef(type)         SWIG_SetErrorMsg(SWIG_ValueError, SWIG_OutNullRefFmt(type))

#define SWIG_set_errmsg(code,msg...)  SWIG_SetErrorMsg(code,msg)
#define SWIG_set_errobj(code,obj)     SWIG_SetErrorObj(code,obj)

#define SWIG_error_block(Block...)    SWIG_block(Block)

#define SWIG_arg_fail(code, type, arg)     SWIG_error_block(SWIG_ArgFail(code, type, arg); SWIG_fail)
#define SWIG_arg_nullref(type, arg)        SWIG_error_block(SWIG_ArgNullRef(type, arg); SWIG_fail)

#define SWIG_member_fail(code, type, name) SWIG_error_block(SWIG_VarFail(code, type, name); SWIG_fail)
#define SWIG_member_nullref(type, name)    SWIG_error_block(SWIG_VarNullRef(type, name); SWIG_fail)

#define SWIG_global_fail(code, type, name) SWIG_error_block(SWIG_VarFail(code, type, name); SWIG_fail)
#define SWIG_global_nullref(type, name)    SWIG_error_block(SWIG_VarNullRef(type, name); SWIG_fail)

#define SWIG_var_fail(code, type, name)    SWIG_error_block(SWIG_VarFail(code, type, name); SWIG_var_fail)
#define SWIG_var_nullref(type, name)       SWIG_error_block(SWIG_VarNullRef(type, name); SWIG_var_fail)

#define SWIG_dout_fail(code, type)         SWIG_DirOutFail(code, SWIG_OutFailFmt(type))
#define SWIG_dout_nullref(type)            SWIG_DirOutFail(SWIG_ValueError, SWIG_OutNullRefFmt(type))


#define SWIG_exception_obj(desc, type, obj) SWIG_error_block(SWIG_ExceptionObj(desc, type, obj); SWIG_fail)


/* 
   Macros to define and check the Language dependent Swig object
   
   Use it, for example in Tcl, as
   
     %define_swig_object(Tcl_Obj)   
*/

#define SWIG_Object __NULL__
%define %define_swig_object(Obj)
#undef  SWIG_Object
#define SWIG_Object Obj
%enddef

%define %check_swig_object()
#if SWIG_str(SWIG_Object) == "__NULL__"
#error "SWIG_Object must be defined using %define_swig_object"
#endif
%enddef

/* -----------------------------------------------------------------------------
 * Auxiliar macros used to write typemaps
 * ----------------------------------------------------------------------------- */

/* define a new macro */
%define SWIG_define(Def, Val)
%#define Def Val
%enddef

/* include C++ or C value */
%define SWIG_cplusplus(cppval, cval)
#ifdef __cplusplus
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


