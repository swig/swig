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
#  define SWIGINTERN static SWIGUNUSED
#endif

#ifndef SWIGINTERNINLINE
#  define SWIGINTERNINLINE SWIGINTERN SWIGINLINE
#endif

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
 * Alloc. memory flags
 * ----------------------------------------------------------------------------- */
#define SWIG_OLDOBJ  1
#define SWIG_NEWOBJ  SWIG_OLDOBJ + 1
#define SWIG_PYSTR   SWIG_NEWOBJ + 1

#ifdef __cplusplus
}
#endif

