/*
 * POINTER
 */

%fragment(SWIG_AsPtr_frag(std::string), "header", fragment="SwigScilabStringToString") {
#define SWIG_AsPtr_std_string(scilabValue, stringPointer) SwigScilabStringToString(pvApiCtx, scilabValue, stringPointer, fname)
}
%fragment(SWIG_From_frag(std::string), "header", fragment="SwigScilabStringFromString") {
#define SWIG_From_std_string(stringPointer) SwigScilabStringFromString(pvApiCtx, $result, stringPointer)
}

%fragment("SwigScilabStringToString", "header", fragment="SwigScilabStringToCharPtrAndSize") {
SWIGINTERN int
SwigScilabStringToString(void *_pvApiCtx, int _iVar, std::string **_pstValue, char *_fname) {
  char* buf = 0;
  size_t size = 0;
  int alloc = SWIG_OLDOBJ;

  if (SWIG_IsOK((SwigScilabStringToCharPtrAndSize(_pvApiCtx, _iVar, &buf, &size, &alloc, _fname)))) {
    if (buf) {
      if (_pstValue) {
        *_pstValue = new std::string(buf, size);
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

%fragment("SwigScilabStringFromString", "header", fragment="SwigScilabStringFromCharPtrAndSize") {
SWIGINTERN int
SwigScilabStringFromString(void *_pvApiCtx, int _iVarOut, std::string _pstValue) {
  return SwigScilabStringFromCharPtrAndSize(_pvApiCtx, _iVarOut, _pstValue.c_str());
}
}

%include <typemaps/std_string.swg>
