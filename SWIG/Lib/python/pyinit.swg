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

