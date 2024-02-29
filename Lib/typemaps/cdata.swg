/* -----------------------------------------------------------------------------
 * cdata.swg
 *
 * This library file contains macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Typemaps for returning binary data
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * %cdata(TYPE [, NAME])
 *
 * Convert raw C data to binary
 * ----------------------------------------------------------------------------- */

%define %cdata(TYPE,NAME...)

%insert("header") {
#ifdef __cplusplus
extern "C"  {
#endif
#if #NAME == ""
static SWIGCDATA cdata_##TYPE(TYPE *ptr, size_t nelements)
#else
static SWIGCDATA cdata_##NAME(TYPE *ptr, size_t nelements)
#endif
{
  SWIGCDATA d;
  d.data = (char *) ptr;
#if #TYPE != "void"
  d.len  = nelements*sizeof(TYPE);
#else
  d.len  = nelements;
#endif
   return d;
}
#ifdef __cplusplus
}
#endif 
}

#ifdef __cplusplus
extern "C"
#endif
#if #NAME == ""
SWIGCDATA cdata_##TYPE(TYPE *ptr, size_t nelements = 1);
#else
SWIGCDATA cdata_##NAME(TYPE *ptr, size_t nelements = 1);
#endif
%enddef

%rename(cdata) ::cdata_void(void *ptr, size_t nelements = 1);

%cdata(void);

/* Memory move function. Due to multi-argument typemaps this appears to be wrapped as
void memmove(void *data, const char *s); */
void memmove(void *data, const void *indata, size_t inlen);
