/* -----------------------------------------------------------------------------
 * SWIG API. Portion that goes into the runtime
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------------
 * for internal method declarations
 * ----------------------------------------------------------------------------- */

#ifndef SWIGINTERN
#define SWIGINTERN static 
#endif

#ifndef SWIGINTERNSHORT
#ifdef __cplusplus
#define SWIGINTERNSHORT static inline 
#else /* C case */
#define SWIGINTERNSHORT static 
#endif /* __cplusplus */
#endif

    
/* Common SWIG API */
#define SWIG_ConvertPtr(obj, pp, type, flags)    SWIG_Python_ConvertPtr(obj, pp, type, flags)
#define SWIG_NewPointerObj(p, type, flags)       SWIG_Python_NewPointerObj(p, type, flags)
#define SWIG_MustGetPtr(p, type, argnum, flags)  SWIG_Python_MustGetPtr(p, type, argnum, flags)
 
/* Python-specific SWIG API */
#define SWIG_newvarlink()                             SWIG_Python_newvarlink()
#define SWIG_addvarlink(p, name, get_attr, set_attr)  SWIG_Python_addvarlink(p, name, get_attr, set_attr)
#define SWIG_ConvertPacked(obj, ptr, sz, ty, flags)   SWIG_Python_ConvertPacked(obj, ptr, sz, ty, flags)
#define SWIG_NewPackedObj(ptr, sz, type)              SWIG_Python_NewPackedObj(ptr, sz, type)
#define SWIG_InstallConstants(d, constants)           SWIG_Python_InstallConstants(d, constants)

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

/* -----------------------------------------------------------------------------
 * Constant declarations
 * ----------------------------------------------------------------------------- */

/* Constant Types */
#define SWIG_PY_INT     1
#define SWIG_PY_FLOAT   2
#define SWIG_PY_STRING  3
#define SWIG_PY_POINTER 4
#define SWIG_PY_BINARY  5

/* Constant information structure */
typedef struct swig_const_info {
    int type;
    char *name;
    long lvalue;
    double dvalue;
    void   *pvalue;
    swig_type_info **ptype;
} swig_const_info;

/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */
/*
  Use SWIG_NO_COBJECT_TYPES to force the use of strings to represent
  C/C++ pointers in the python side. Very useful for debugging, but
  not always safe.
*/
#if !defined(SWIG_NO_COBJECT_TYPES) && !defined(SWIG_COBJECT_TYPES)
  //#define SWIG_COBJECT_TYPES
#endif

/* Flags for pointer conversion */
#define SWIG_POINTER_EXCEPTION     0x1
#define SWIG_POINTER_DISOWN        0x2

/* -----------------------------------------------------------------------------
 * Alloc. memory flags
 * ----------------------------------------------------------------------------- */
#define SWIG_OLDOBJ  1
#define SWIG_NEWOBJ  SWIG_OLDOBJ + 1
#define SWIG_PYSTR   SWIG_NEWOBJ + 1

#ifdef __cplusplus
}
#endif

