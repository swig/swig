%include <wchar.i>
%include <std_basic_string.i>

/* wide strings */

namespace std
{
  %std_comp_methods(basic_string<wchar_t>);
  typedef basic_string<wchar_t> wstring;
}

/* defining the std::string asptr/from methods */

%fragment(SWIG_AsPtr_frag(std::basic_string<wchar_t>),"header",
	  fragment="SWIG_AsWCharPtrAndSize") {
SWIGINTERN int
  SWIG_AsPtr(std::basic_string<wchar_t>)(PyObject* obj, std::wstring **val)
  {
    static swig_type_info* string_info = SWIG_TypeQuery("std::wstring *");
    std::wstring *vptr;    
    if (SWIG_ConvertPtr(obj, (void**)&vptr, string_info, 0) != -1) {
      if (val) *val = vptr;
      return SWIG_OLDOBJ;
    } else {
      PyErr_Clear();
      wchar_t *buf = 0 ; size_t size = 0;
      int res = 0;
      if ((res = SWIG_AsWCharPtrAndSize(obj, &buf, &size))) {
	if (buf) {
	  if (val) *val = new std::wstring(buf, size - 1);
	  if (res == SWIG_NEWOBJ) SWIG_delete_array(buf);
	  return SWIG_NEWOBJ;
	}
      } else {
	PyErr_Clear();
      }  
      if (val) {
	PyErr_SetString(PyExc_TypeError,"a wstring is expected");
      }
      return 0;
    }
  }
  
SWIGINTERNSHORT int
  SWIG_AsPtr(std::wstring)(PyObject* obj, std::wstring **val)
  {
    return SWIG_AsPtr(std::basic_string<wchar_t>)(obj, val);
  }
}

%fragment(SWIG_From_frag(std::basic_string<wchar_t>),"header",
	  fragment="SWIG_FromWCharArray") {
SWIGINTERNSHORT PyObject*
  SWIG_From(std::basic_string<wchar_t>)(const std::wstring& s)
  {
    return SWIG_FromWCharArray(s.data(), s.size());
  }

SWIGINTERNSHORT PyObject*
  SWIG_From(std::wstring)(const std::wstring& s)
  {
    return SWIG_From(std::basic_string<wchar_t>)(s);
  }
}


%fragment(SWIG_AsVal_frag(std::wstring),"header",
          fragment=SWIG_AsPtr_frag(std::basic_string<wchar_t>)) {
SWIGINTERN int
  SWIG_AsVal(std::wstring)(PyObject* obj, std::wstring *val)
  {
    std::wstring *s;
    int res = SWIG_AsPtr(std::basic_string<wchar_t>)(obj, &s);
    if (res && s) {
      if (val) *val = *s;
      if (res == SWIG_NEWOBJ) delete s;
      return res;
    }
    if (val) {
      PyErr_SetString(PyExc_TypeError,"a wstring is expected");
    }
    return 0;
  }
}

%typemap_asptrfromn(SWIG_CCode(UNISTRING), std::basic_string<wchar_t>);
%typemap_asptrfromn(SWIG_CCode(UNISTRING), std::wstring);
