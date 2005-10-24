/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(VALUE obj, char** cptr, size_t* psize, int *alloc)
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
    if (TYPE(obj) == T_STRING) {
      char *cstr = rb_string_value_ptr(&(obj)); 
      size_t size = RSTRING(obj)->len + 1;
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
SWIGINTERNINLINE VALUE 
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > LONG_MAX) {
      return SWIG_NewPointerObj(%const_cast(carray,char *), SWIG_TypeQuery("char *"), 0);
    } else {
      return rb_str_new(carray, %numeric_cast(size,long));
    }
  } else {
    return Qnil;
  }
}
}

