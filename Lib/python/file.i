/*
  Typemaps for FILE*

  From the ideas of Luigi 
  luigi.ballabio@fastwebnet.it
*/

%types(FILE *);

/* defining basic methods */
%fragment("SWIG_AsValFilePtr","header") {
SWIGINTERN int
SWIG_AsValFilePtr(PyObject *obj, FILE **val) {
  static swig_type_info* desc = 0;
  FILE *ptr = 0;
  if (!desc) desc = SWIG_TypeQuery("FILE *");
  if ((SWIG_ConvertPtr(obj,(void **)(&ptr), desc, 0)) != -1) {
    if (val) *val = ptr;
    return 1;
  } 
  if (PyFile_Check(obj)) {
    if (val) *val =  PyFile_AsFile(obj);
    return 1;
  }
  if (val) PyErr_SetString(PyExc_TypeError, "a FILE* is expected");
  return 0;
}
}

%fragment("SWIG_AsFilePtr","header",fragment="SWIG_AsValFilePtr") {
SWIGINTERNINLINE FILE*
SWIG_AsFilePtr(PyObject *obj) {
  FILE *val = 0;
  SWIG_AsValFilePtr(obj, &val);
  return val;
}
}

%fragment("SWIG_CheckFilePtr","header",fragment="SWIG_AsValFilePtr") {
SWIGINTERNINLINE int
SWIG_CheckFilePtr(PyObject *obj) {
  return SWIG_AsValFilePtr(obj, (FILE **)(0));
}
}

/* defining the typemaps */
%typemap_ascheck(SWIG_CCode(POINTER), SWIG_AsFilePtr, SWIG_CheckFilePtr,
		 "SWIG_AsFilePtr", "SWIG_CheckFilePtr", FILE*);
