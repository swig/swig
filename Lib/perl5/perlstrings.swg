/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(SV *obj, char** cptr, size_t* psize, int *alloc)
{
  static swig_type_info* pchar_info = 0;
  char* vptr = 0;
  if (!pchar_info) pchar_info = SWIG_TypeQuery("char *");
  if (SWIG_ConvertPtr(obj, (void**)&vptr, pchar_info, 0) == SWIG_OK) {
    if (cptr) *cptr = vptr;
    if (psize) *psize = vptr ? (strlen(vptr) + 1) : 0;
    if (alloc) *alloc = SWIG_OLDOBJ;
    return SWIG_OK;
  } else {
    if (SvPOK(obj)) {
      STRLEN len = 0;
      char *cstr = SvPV(obj, len); 
      size_t size = len + 1;
      if (cptr)  {
	if (alloc) {
	  if (*alloc == SWIG_NEWOBJ) {
	    *cptr = %new_copy_array(cstr, size, char);
	  } else {
	    *cptr = cstr;
	    *alloc = SWIG_OLDOBJ;
	  }
	}
      }
      if (psize) *psize = size;
      return SWIG_OK;
    }
  }
  return SWIG_TypeError;
}
}

%fragment("SWIG_FromCharPtrAndSize","header") {
SWIGINTERNINLINE SV *
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
  SV *obj = sv_newmortal();
  if (size && carray) {
    if (carray[size - 1] == 0) {
      sv_setpv(obj, carray);
    } else {
      char *tmp = %new_array(size + 1, char);
      memcpy(tmp, carray, size);
      tmp[size] = 0;
      sv_setpv(obj, tmp);
      %delete_array(tmp);
    }
  } else {
    sv_setsv(obj, &PL_sv_undef);
  }
  return obj;
}
}

