//
// SWIG typemaps for std::string
// Luigi Ballabio
// Apr 8, 2002
//
// Python implementation

// ------------------------------------------------------------------------
// std::string is typemapped by value
// This can prevent exporting methods which return a string
// in order for the user to modify it.
// However, I think I'll wait until someone asks for it...
// ------------------------------------------------------------------------

%{
#include <string>
%}

/* defining the std::string as/from converters */

%fragment("SWIG_PyObj_AsStdString","header") %{
static inline std::string
SWIG_PyObj_AsStdString(PyObject* obj) {
  static swig_type_info* pchar_info = SWIG_TypeQuery("char *");
  char* buf = 0 ; size_t size = 0;
  SWIG_PyObj_AsCharPtrAndSize(obj, pchar_info, &buf, &size);
  if (PyErr_Occurred() || !buf) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError,"a string is expected");
    return std::string();    
  }
  return std::string(buf, size);
}
%}

%fragment("SWIG_PyObj_CheckStdString","header") %{
static inline void
SWIG_PyObj_CheckStdString(PyObject* obj) {
  static swig_type_info* pchar_info = SWIG_TypeQuery("char *");
  char* buf = 0; size_t size = 0;
  SWIG_PyObj_AsCharPtrAndSize(obj, pchar_info, &buf, &size);
  if (PyErr_Occurred() || !buf) {
    PyErr_Clear();
    PyErr_SetString(PyExc_TypeError,"a string is expected");
  }
}
%}

%fragment("SWIG_PyObj_FromStdString","header") %{
static inline PyObject* 
SWIG_PyObj_FromStdString(const std::string& s) {
  return SWIG_PyObj_FromCharArray(s.data(), s.size());
}
%}


/* declaring the typemaps */

%typemap_asfromcheck(std::string, STRING, 
		     SWIG_PyObj_AsStdString, SWIG_PyObj_FromStdString,
		     SWIG_PyObj_CheckStdString);
