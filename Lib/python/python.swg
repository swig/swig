/* -----------------------------------------------------------------------------
 * python.swg
 *
 * Python configuration module.
 * ----------------------------------------------------------------------------- */

/* Python.h has to appear first */

%insert(runtime) %{
#include "Python.h"
%}

%insert(runtime) "precommon.swg";
%insert(runtime) "common.swg";          /* Common type-checking code */
%insert(runtime) "pyrun.swg";           /* Python run-time code */

/* Special directive for shadow code */

#define %shadow      %insert("shadow")
#define %pythoncode  %insert("python")

%{
/* Auxiliar swig  macros */

#ifdef __cplusplus
#define SWIGSTATICINLINE(a) static inline a
#define SWIGSTATIC(a) static a
#define swig_new_array(type, size) (new type[(size)])
#define swig_delete_array(cptr) delete[] cptr
#define swig_const_cast(type,a) const_cast<type>(a)
#define swig_static_cast(type,a) static_cast<type>(a)
#define swig_reinterpret_cast(type,a) reinterpret_cast<type>(a)

#ifdef HAVE_NUMERIC_CAST
#define swig_numeric_cast(type,a) numeric_cast<type>(a)
#else
#define swig_numeric_cast(type,a) static_cast<type>(a)
#endif

#else /* C case */

#define SWIGSTATICINLINE(a) static a
#define SWIGSTATIC(a) static a
#define swig_new_array(type, size) ((type*) malloc((size)*sizeof(type)))
#define swig_delete_array(cptr) free((char*)cptr)
#define swig_const_cast(type,a) (type)(a)
#define swig_static_cast(type,a) (type)(a)
#define swig_reinterpret_cast(type,a) (type)(a)
#define swig_numeric_cast(type,a) (type)(a)

#endif /* __cplusplus */
%}

/* -----------------------------------------------------------------------------
 *  SWIGTYPE typemaps
 * ----------------------------------------------------------------------------- */

%include "pyswigtype.swg"

/* -----------------------------------------------------------------------------
 *  Typemap specializations
 * ----------------------------------------------------------------------------- */
%include "pyvoid.swg"
%include "pyobject.swg"
%include "pystrings.swg"
%include "pyvaltypes.swg"
%include "pyprimtypes.swg"
%include "pymisctypes.swg"

/* ------------------------------------------------------------
 *  Enums 
 * ------------------------------------------------------------ */
%apply int { enum SWIGTYPE };
/* this doesn't work now, you need to redefined it for each enum. */
%apply const int& { const enum SWIGTYPE& };


/* ------------------------------------------------------------
 *  Overloaded operator support
 * ------------------------------------------------------------ */
%include "pyopers.swg"

/* ------------------------------------------------------------
 * Warnings for Python keywords 
 * ------------------------------------------------------------ */
%include "pythonkw.swg"

/* ------------------------------------------------------------
 * The start of the Python initialization function 
 * ------------------------------------------------------------ */

%init %{
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) SWIG_init(void) {
  static PyObject *SWIG_globals = 0; 
  static int       typeinit = 0;
  PyObject *m, *d;
  int       i;
  if (!SWIG_globals) SWIG_globals = SWIG_newvarlink();
  m = Py_InitModule((char *) SWIG_name, SwigMethods);
  d = PyModule_GetDict(m);

  if (!typeinit) {
     for (i = 0; swig_types_initial[i]; i++) {
        swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
     }
     typeinit = 1;
  }
  SWIG_InstallConstants(d,swig_const_table);
%}
