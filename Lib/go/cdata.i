/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data as strings.
 * ----------------------------------------------------------------------------- */

%{
typedef struct SWIGCDATA {
    char *data;
    int   len;
} SWIGCDATA;
%}

%typemap(gotype) SWIGCDATA %{ []byte %}
%typemap(out) SWIGCDATA (swigcdata argp) {
  argp = _swig_makegobyteslice($1.data, $1.len);
  $result.data = (char*)argp.data;
  $result.len = (int)argp.len;
}

/* The makegobyteslice function.  */

%insert(runtime) %{
typedef struct {
  char *data;
  int len;
} swigcdata;

%}

#ifndef SWIGGO_GCCGO
%insert(runtime) %{
extern
#ifdef __cplusplus
"C"
#endif
void _swig_gc_makegobyteslice(void *, int);
static swigcdata _swig_makegobyteslice(const char *data, int len) {
  struct {
    const char *data;
    int len;
    swigcdata ret;
  } a;
  a.data = data;
  a.len = len;
  crosscall2(_swig_gc_makegobyteslice, &a, (int) sizeof a);
  return a.ret;
}
%}

%insert(gc_header) %{
typedef struct {
	byte *data;
	int32 len;
} swigcdata;
extern void ·_swig_internal_makegobyteslice(void);
#pragma dynexport _swig_gc_makegobyteslice _swig_gc_makegobyteslice
void _swig_gc_makegobyteslice(void *a, int32 n) {
	cgocallback(·_swig_internal_makegobyteslice, a, n);
}
void ·_swig_allocategobyteslice(byte *data, int32 len, swigcdata ret) {
	ret.data = runtime·mal(len);
	runtime·mcpy(ret.data, data, len);
	ret.len = len;
	FLUSH(&ret);
}
%}

%insert(go_header) %{
type swigcdata struct { data *byte; len int }
func _swig_allocategobyteslice(*byte, int) swigcdata
func _swig_internal_makegobyteslice(data *byte, len int) swigcdata {
	return _swig_allocategobyteslice(data, len)
}
%}

#else

%insert(runtime) %{
static swigcdata _swig_makegobyteslice(const char *data, int len) {
  swigcdata ret;
  ret.data = (char*)__go_alloc(len);
  memcpy(ret.data, data, len);
  ret.len = (int)len;
  return ret;
}

%}

#endif

/* -----------------------------------------------------------------------------
 * %cdata(TYPE [, NAME]) 
 *
 * Convert raw C data to a binary string.
 * ----------------------------------------------------------------------------- */

%define %cdata(TYPE,NAME...)

%insert("header") {
#if #NAME == ""
static SWIGCDATA cdata_##TYPE(TYPE *ptr, int nelements) {
#else
static SWIGCDATA cdata_##NAME(TYPE *ptr, int nelements) {
#endif
   SWIGCDATA d;
   d.data = (char *) ptr;
#if #TYPE != "void"
   d.len  = nelements*sizeof(TYPE);
#else
   d.len  = nelements;
#endif
   return d;
}
}

%typemap(default) int nelements "$1 = 1;"

#if #NAME == ""
SWIGCDATA cdata_##TYPE(TYPE *ptr, int nelements);
#else
SWIGCDATA cdata_##NAME(TYPE *ptr, int nelements);
#endif
%enddef

%typemap(default) int nelements;

%rename(cdata) ::cdata_void(void *ptr, int nelements);

%cdata(void);

/* Memory move function. Due to multi-argument typemaps this appears
   to be wrapped as
   void memmove(void *data, const char *s); */
void memmove(void *data, char *indata, int inlen);
