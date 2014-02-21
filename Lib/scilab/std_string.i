/*
 * POINTER
 */
%fragment(SWIG_AsPtr_frag(std::string), "header", fragment="SWIG_SciString_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsPtr_dec(std::string)(int _iVar, std::string **_pstValue) {
  char* buf = 0;
  size_t size = 0;
  int alloc = SWIG_OLDOBJ;

  if (SWIG_IsOK((SWIG_SciString_AsCharPtrAndSize(pvApiCtx, _iVar, &buf, &size, &alloc, SWIG_Scilab_GetFname())))) {
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

%fragment(SWIG_From_frag(std::string), "header", fragment="SWIG_SciString_FromCharPtr") {
SWIGINTERN int
SWIG_From_dec(std::string)(std::string _pstValue) {
    return SWIG_SciString_FromCharPtr(pvApiCtx, SWIG_Scilab_GetOutputPosition(), _pstValue.c_str());
}
}

%include <typemaps/std_string.swg>
