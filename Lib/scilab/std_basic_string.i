/*
 * C++: basic_string<char>
 * Scilab: string
 */

#if !defined(SWIG_STD_STRING)
#define SWIG_STD_BASIC_STRING

#define %swig_basic_string(Type...)  %swig_sequence_methods_val(Type)

%fragment(SWIG_AsPtr_frag(std::basic_string<char>), "header", fragment="SWIG_SciString_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsPtr_dec(std::basic_string<char>)(int _iVar, std::basic_string<char> **_pstValue) {
  char* buf = 0;
  size_t len = 0;
  int alloc = SWIG_OLDOBJ;

  if (SWIG_IsOK((SWIG_SciString_AsCharPtrAndSize(pvApiCtx, _iVar, &buf, &len, &alloc, SWIG_Scilab_GetFuncName())))) {
    if (buf) {
      if (_pstValue) {
        *_pstValue = new std::string(buf, len - 1);
      }
      if (alloc == SWIG_NEWOBJ) {
        delete[] buf;
      }
      return SWIG_NEWOBJ;
    } else {
      if (_pstValue) {
        *_pstValue = NULL;
      }
      return SWIG_OLDOBJ;
    }
  } else {
    return SWIG_ERROR;
  }
}
}

%fragment(SWIG_From_frag(std::basic_string<char>), "header", fragment="SWIG_SciString_FromCharPtr") {
SWIGINTERN int
SWIG_From_dec(std::basic_string<char>)(std::basic_string<char> _pstValue) {
    return SWIG_SciString_FromCharPtr(pvApiCtx, SWIG_Scilab_GetOutputPosition(), _pstValue.c_str());
}
}

%ignore std::basic_string::operator +=;
%ignore std::basic_string::operator ==;
%ignore std::basic_string::operator !=;
%ignore std::basic_string::operator <;
%ignore std::basic_string::operator >;
%ignore std::basic_string::operator <=;
%ignore std::basic_string::operator >=;

%include <std/std_basic_string.i>
%typemaps_asptrfromn(%checkcode(STRING), std::basic_string<char>);

#endif

