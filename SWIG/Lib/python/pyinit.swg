/* ------------------------------------------------------------
 * The start of the Python initialization function 
 * ------------------------------------------------------------ */

%init %{

#ifdef SWIG_LINK_RUNTIME
#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#  if defined(_MSC_VER) || defined(__GNUC__)
#    define SWIGIMPORT(a) extern a
#  else
#    if defined(__BORLANDC__)
#      define SWIGIMPORT(a) a _export
#    else
#      define SWIGIMPORT(a) a
#    endif
#  endif
#else
#  define SWIGIMPORT(a) a
#endif
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void *) SWIG_ReturnGlobalTypeList(void *);
#endif
 
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) SWIG_init(void) {
  static PyObject *SWIG_globals = 0; 
  static int       typeinit = 0;
  PyObject *m, *d;
  int       i;
  if (!SWIG_globals) SWIG_globals = SWIG_newvarlink();

  /* Fix SwigMethods to carry the callback ptrs when needed */
  SWIG_Python_FixMethods(SwigMethods, swig_const_table, swig_types, swig_types_initial);
  
  m = Py_InitModule((char *) SWIG_name, SwigMethods);
  d = PyModule_GetDict(m);

  if (!typeinit) {
#ifdef SWIG_LINK_RUNTIME
    swig_type_list_handle = (swig_type_info **) SWIG_ReturnGlobalTypeList(swig_type_list_handle);
#else
#  ifndef SWIG_STATIC_RUNTIME
    SWIG_Python_LookupTypePointer(&swig_type_list_handle);
#  endif
#endif
    for (i = 0; swig_types_initial[i]; i++) {
      swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }
    typeinit = 1;
  }
  SWIG_InstallConstants(d,swig_const_table);
%}

