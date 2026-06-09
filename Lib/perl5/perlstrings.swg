/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(SV *obj, char** cptr, size_t* psize, int *alloc)
{
  int is_binary = (alloc != NULL) && SWIG_IsBinaryStr(*alloc);
  if (SvMAGICAL(obj)) {
     SV *tmp = sv_newmortal();
     SvSetSV(tmp, obj);
     obj = tmp;
  }
  if (SvPOK(obj)) {
    STRLEN len = 0;
    char *cstr = SvPV(obj, len);
    size_t size = is_binary ? len : len + 1;
    if (cptr) {
      if (alloc) {
	if (SWIG_IsNewObj(*alloc)) {
	  char* p = %new_array(size, char);
	  if (p == NULL) {
	    return SWIG_MemoryError;
	  }
	  memcpy(p, cstr, size);
	  *cptr = p;
	} else {
	  *cptr = cstr;
	  *alloc = SWIG_OLDOBJ;
	}
      }
    }
    if (psize) *psize = size;
    return SWIG_OK;
  } else {
    swig_type_info* pchar_descriptor = SWIG_pchar_descriptor();
    if (pchar_descriptor) {
      char* vptr = 0; 
      if (SWIG_ConvertPtr(obj, (void**)&vptr, pchar_descriptor, 0) == SWIG_OK) {
	if (cptr) *cptr = vptr;
	if (psize) *psize = vptr ? (strlen(vptr) + 1) : 0;
	if (alloc) *alloc = SWIG_OLDOBJ;
	return SWIG_OK;
      }
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromCharPtrAndSize","header") {
#define SWIG_FromBinaryCharPtrAndSize(carray, size, flags) SWIG_FromCharPtrAndSize(carray, size)
SWIGINTERNINLINE SV *
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
  SV *obj = sv_newmortal();
  if (carray) {
    sv_setpvn(obj, carray, size);
  } else {
    sv_setsv(obj, &PL_sv_undef);
  }
  return obj;
}
}

