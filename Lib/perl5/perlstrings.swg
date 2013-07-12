/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header",fragment="SWIG_pchar_descriptor") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(SV *obj, char** cptr, size_t* psize, int *alloc)
{
  if (SvMAGICAL(obj)) {
     SV *tmp = sv_newmortal();
     SvSetSV(tmp, obj);
     obj = tmp;
  }
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

  {
  /* not char*, try to cast the scalar to string */
    STRLEN len = 0;
    char *cstr = SvPV(obj, len);
	if (!cstr) {
		return SWIG_TypeError;
	}
    size_t size = len + 1;
	if (cptr && alloc)  {
		if (*alloc == SWIG_NEWOBJ) {
			*cptr = %new_copy_array(cstr, size, char);
		} else {
			*cptr = cstr;
			*alloc = SWIG_OLDOBJ;
		}
	}
    if (psize) *psize = size;
    return SWIG_OK;
  }
}
}

%fragment("SWIG_FromCharPtrAndSize","header") {
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

