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

/* defining the std::string as/from/check methods */

%fragment("SWIG_TryStdString","header",
	  fragment="SWIG_AsCharPtrAndSize") %{
SWIGSTATICINLINE(int)
SWIG_TryStdString(PyObject* obj, char*& buf, size_t& size) {
  SWIG_AsCharPtrAndSize(obj, &buf, &size);
  if (PyErr_Occurred() || !buf) {
    if (PyErr_Occurred()) PyErr_Clear();
    return 0;
  }
  return 1;
}
%}

%fragment("SWIG_CheckStdString","header",
	  fragment="SWIG_TryStdString") %{
SWIGSTATICINLINE(int)
SWIG_CheckStdString(PyObject* obj) {
  char* buf = 0 ; size_t size = 0;
  return SWIG_TryStdString(obj, buf, size);
}
%}


%fragment("SWIG_AsStdString","header",
	  fragment="SWIG_TryStdString") %{
SWIGSTATICINLINE(std::string)
SWIG_AsStdString(PyObject* obj) {
  char* buf = 0 ; size_t size = 0;
  if (SWIG_TryStdString(obj, buf, size)) {
    return std::string(buf, size);
  } else {
    PyErr_SetString(PyExc_TypeError,"a string is expected");
    return std::string();
  }
}
%}

%fragment("SWIG_FromStdString","header",
	  fragment="SWIG_FromCharArray") %{
SWIGSTATICINLINE(PyObject*)
SWIG_FromStdString(const std::string& s) {
  return SWIG_FromCharArray(s.data(), s.size());
}
%}

/* declaring the typemaps */

%typemap_asfromcheck(std::string, STRING,
		     SWIG_AsStdString,
		     SWIG_FromStdString,
		     SWIG_CheckStdString);
