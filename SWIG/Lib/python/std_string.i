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


/* defining the std::string as/from methods */

%fragment(SWIG_AsVal_frag(std::string),"header",
	  fragment="SWIG_AsCharPtrAndSize") {
SWIGSTATICINLINE(int)
  SWIG_AsVal_meth(std::string)(PyObject* obj, std::string *val)
{
  char* buf = 0 ; size_t size = 0;
  if (SWIG_AsCharPtrAndSize(obj, &buf, &size)) {
    if (buf) {
      if (val) val->assign(buf, size);
      return 1;
    }
  } else {
    PyErr_Clear();
  }  
  if (val) {
    PyErr_SetString(PyExc_TypeError,"a string is expected");
  }
  return 0;
}
}

%fragment(SWIG_From_frag(std::string),"header",
	  fragment="SWIG_FromCharArray") {
SWIGSTATICINLINE(PyObject*)
  SWIG_From_meth(std::string)(const std::string& s) {
  return SWIG_FromCharArray(s.data(), s.size());
}
}

%typemap_primitive(SWIG_CCode(STRING),  std::string);

/* declaring the typemaps */
