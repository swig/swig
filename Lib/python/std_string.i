//
// std::string
//

#ifndef SWIG_STD_BASIC_STRING
#define SWIG_STD_STRING

%{
#include <string>
%}
  
%include <pystrings.swg>

namespace std
{
  class string;
}


/* defining the std::string asptr/from methods */


%fragment(SWIG_AsPtr_frag(std::string),"header",
	  fragment="SWIG_AsCharPtrAndSize") {
  SWIGINTERN int
    SWIG_AsPtr(std::string)(PyObject* obj, std::string **val)
    {
      static swig_type_info* string_info = SWIG_TypeQuery("std::string *");
      std::string *vptr;    
      if (SWIG_ConvertPtr(obj, (void**)&vptr, string_info, 0) != -1) {
	if (val) *val = vptr;
	return SWIG_OLDOBJ;
      } else {
	PyErr_Clear();
	char* buf = 0 ; size_t size = 0;
	if (SWIG_AsCharPtrAndSize(obj, &buf, &size)) {
	  if (buf) {
	    if (val) *val = new std::string(buf, size - 1);
	    return SWIG_NEWOBJ;
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
}

%fragment(SWIG_From_frag(std::string),"header",
	  fragment="SWIG_FromCharArray") {
SWIGINTERNINLINE PyObject*
  SWIG_From(std::string)(const std::string& s)
  {
    return SWIG_FromCharArray(s.data(), s.size());
  }
}

%fragment(SWIG_AsVal_frag(std::string),"header",
          fragment=SWIG_AsPtr_frag(std::string)) {
SWIGINTERN int
  SWIG_AsVal(std::string)(PyObject* obj, std::string *val)
  {
    std::string* s;
    int res = SWIG_AsPtr(std::string)(obj, &s);
    if ((res != 0) && s) {
      if (val) *val = *s;
      if (res == SWIG_NEWOBJ) delete s;
      return res;
    }
    if (val) {
      PyErr_SetString(PyExc_TypeError,"a string is expected");
    }
    return 0;
  }
}

%typemap_asptrfromn(SWIG_CCode(STRING), std::string);

#else

%include <std/std_string.i>

#endif
