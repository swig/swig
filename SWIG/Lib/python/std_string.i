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

%include <pystrings.swg>
%include <std_basic_string.i>

/* plain strings */

namespace std
{
  %std_comp_methods(basic_string<char>);
  typedef basic_string<char> string;
}

/* defining the std::string asptr/from methods */

%fragment(SWIG_AsPtr_frag(std::basic_string<char>),"header",
	  fragment="SWIG_AsCharPtrAndSize") {
  SWIGINTERN int
    SWIG_AsPtr(std::basic_string<char>)(PyObject* obj, std::string **val)
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
  
  SWIGINTERNSHORT int
    SWIG_AsPtr(std::string)(PyObject* obj, std::string **val)
    {
      return SWIG_AsPtr(std::basic_string<char>)(obj, val);
   }
}

%fragment(SWIG_From_frag(std::basic_string<char>),"header",
	  fragment="SWIG_FromCharArray") {
SWIGINTERNSHORT PyObject*
  SWIG_From(std::basic_string<char>)(const std::string& s)
  {
    return SWIG_FromCharArray(s.data(), s.size());
  }

SWIGINTERNSHORT PyObject*
  SWIG_From(std::string)(const std::string& s)
  {
    return SWIG_From(std::basic_string<char>)(s);
  }
}


%fragment(SWIG_AsVal_frag(std::string),"header",
          fragment=SWIG_AsPtr_frag(std::basic_string<char>)) {
SWIGINTERN int
  SWIG_AsVal(std::string)(PyObject* obj, std::string *val)
  {
    std::string* s;
    int res = SWIG_AsPtr(std::basic_string<char>)(obj, &s);
    if (res && s) {
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


%typemap_asptrfromn(SWIG_CCode(STRING), std::basic_string<char>);
%typemap_asptrfromn(SWIG_CCode(STRING), std::string);
