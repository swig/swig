/* -----------------------------------------------------------------------------
 * cdata.swg
 *
 * This library file contains macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

#ifdef SWIGGO
#define swig_cdata_nelems_type int
#else
#define swig_cdata_nelems_type size_t
#endif

%{
typedef struct SWIGCDATA {
    char *data;
#ifdef SWIGGO
    intgo len;
#else
    size_t   len;
#endif
} SWIGCDATA;
%}

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

#if !defined SWIGJAVA && !defined SWIGGO && !defined SWIGD && !defined SWIGPHP &&\
    !defined SWIGGUILE && !defined SWIGCSHARP && !defined SWIGLUA &&\
    !defined SWIGMZSCHEME

%typemap(in,noblock=0,fragment="SWIG_AsCharPtrAndSize")
  (const void *BYTES, size_t LENGTH) (int res, void *buf = 0, size_t len = 0, int alloc = 0)
{
  res = SWIG_AsCharPtrAndSize($input, (char **)&buf, &len, &alloc);
  if (!SWIG_IsOK(res)) {
    %argument_fail(res,"$type",$symname, $argnum);
  }
  $1 = %reinterpret_cast(buf, $1_ltype);
  $2 = %numeric_cast(len, $2_ltype);
}

%typemap(freearg,noblock=1,match="in")
  (const void *BYTES, size_t LENGTH)
{
  if (alloc$argnum == SWIG_NEWOBJ) {
    %delete_array((char*)(buf$argnum));
  }
}

%typemap(directorin,noblock=1,fragment="SWIG_FromCharPtrAndSize")
  (const void *BYTES, size_t LENGTH)
{
  if ($1 && $2 > 0) {
    $input = SWIG_FromCharPtrAndSize((const char*)$1, (size_t)$2);
  } else {
    $input = SWIG_FromCharPtrAndSize("", 0);
  }
}

%typemap(in) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(freearg) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(directorin) (void *BYTES, size_t LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(freearg) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(directorin) (const void *BYTES, int LENGTH) = (const void *BYTES, size_t LENGTH);
%typemap(in) (void *BYTES, int LENGTH) = (const void *BYTES, int LENGTH);
%typemap(freearg) (void *BYTES, int LENGTH) = (const void *BYTES, int LENGTH);
%typemap(directorin) (void *BYTES, int LENGTH) = (const void *BYTES, int LENGTH);
%typemap(in) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);
%typemap(freearg) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);
%typemap(directorin) (const void *indata, size_t inlen) = (const void *BYTES, size_t LENGTH);

#else

%apply (const void *BYTES, size_t LENGTH) { (const void *BYTES, int LENGTH) }
%apply (void *BYTES, size_t LENGTH) { (void *BYTES, int LENGTH) }
%apply (const void *BYTES, size_t LENGTH) { (const void *indata, size_t inlen) }

#endif

/* -----------------------------------------------------------------------------
 * Typemaps for returning binary data
 * ----------------------------------------------------------------------------- */

#ifdef SWIGJAVA

%typemap(jni) SWIGCDATA "jbyteArray"
%typemap(jtype) SWIGCDATA "byte[]"
%typemap(jstype) SWIGCDATA "byte[]"
%fragment("SWIG_JavaArrayOutCDATA", "header") {
static jbyteArray SWIG_JavaArrayOutCDATA(JNIEnv *jenv, char *result, jsize sz) {
  jbyteArray jresult;
  jbyte *arr;
  int i;
  jresult = JCALL1(NewByteArray, jenv, sz);
  if (!jresult) {
    return SWIG_NULLPTR;
  }
  arr = JCALL2(GetByteArrayElements, jenv, jresult, 0);
  if (!arr) {
    return SWIG_NULLPTR;
  }
  for (i=0; i<sz; i++) {
    arr[i] = (jbyte)result[i];
  }
  JCALL3(ReleaseByteArrayElements, jenv, jresult, arr, 0);
  return jresult;
}
}
%typemap(out, fragment="SWIG_JavaArrayOutCDATA") SWIGCDATA
%{$result = SWIG_JavaArrayOutCDATA(jenv, (char *)$1.data, $1.len); %}
%typemap(javaout) SWIGCDATA {
    return $jnicall;
  }

#elif SWIGGO

%typemap(gotype) SWIGCDATA "[]byte"
%typemap(imtype) SWIGCDATA "uint64"

%typemap(out, fragment="cdata") SWIGCDATA(struct swigcdata *swig_out) %{
  swig_out = (struct swigcdata *)malloc(sizeof(*swig_out));
  if (swig_out) {
    swig_out->size = $1.len;
    swig_out->data = malloc(swig_out->size);
    if (swig_out->data) {
      memcpy(swig_out->data, $1.data, swig_out->size);
    }
  }
  $result = *(long long *)(void **)&swig_out;
%}

%typemap(goout) SWIGCDATA %{
  {
    type swigcdata struct { size int; data uintptr }
    p := (*swigcdata)(unsafe.Pointer(uintptr($1)))
    if p == nil || p.data == 0 {
      $result = nil
    } else {
      b := make([]byte, p.size)
      a := (*[0x7fffffff]byte)(unsafe.Pointer(p.data))[:p.size]
      copy(b, a)
      Swig_free(p.data)
      Swig_free(uintptr(unsafe.Pointer(p)))
      $result = b
    }
  }
%}

#elif SWIGD

%typemap(dtype) SWIGCDATA "ubyte[]"
%typemap(imtype) SWIGCDATA "ubyte[]"
%typemap(ctype) SWIGCDATA "SWIG_c_array"
%typemap(out) SWIGCDATA %{
  $result.array = $1.data;
  $result.len = $1.len;
%}
%typemap(dout) SWIGCDATA { return $imcall; }

#elif SWIGPHP

%typemap(out) SWIGCDATA {
  ZVAL_STRINGL($result, $1.data, $1.len);
}

#elif SWIGGUILE

%typemap(out) SWIGCDATA {
   $result = scm_from_locale_stringn($1.data,$1.len);
}

#elif SWIGCSHARP

%pragma(csharp) imclasscode=%{
  [global::System.Runtime.InteropServices.DllImport("$module", EntryPoint="SWIG_csharp_data")]
  public static extern int SWIG_csharp_data(global::System.IntPtr data, ref global::System.IntPtr m);
%}

%fragment("SWIG_csharp_data", "header") %{
#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORT int SWIGSTDCALL SWIG_csharp_data(SWIGCDATA *d, void **ptr) {
    int ret;
    ret = 0;
    if (d != SWIG_NULLPTR) {
        if (d->len > 0 && d->data != SWIG_NULLPTR) {
            *ptr = (void *)d->data;
            ret = (int)d->len;
        }
        free(d); /* allocated in 'out' typemap */
    }
    return ret;
}

#ifdef __cplusplus
}
#endif
%}

%typemap(ctype)  SWIGCDATA "SWIGCDATA *"
%typemap(imtype) SWIGCDATA "global::System.IntPtr"
%typemap(cstype) SWIGCDATA "byte[]"
%typemap(out)    SWIGCDATA %{
    $result = (SWIGCDATA*)malloc(sizeof($1));
    if($result != SWIG_NULLPTR) {
        memcpy($result, &$1, sizeof($1));
    }
%}
%typemap(csout, fragment="SWIG_csharp_data") SWIGCDATA {
    global::System.IntPtr mm;
    byte[] ret;
    int size;
    mm = global::System.IntPtr.Zero;
    size = $modulePINVOKE.SWIG_csharp_data($imcall, ref mm);
    ret = new byte[size];
    if (size > 0) {
        System.Runtime.InteropServices.Marshal.Copy(mm, ret, 0, size);
    }
    return ret;
}

#elif SWIGLUA

%typemap(out) SWIGCDATA %{lua_pushlstring(L, $1.data,$1.len); SWIG_arg++;%}

#elif SWIGMZSCHEME

#else

%typemap(out,noblock=1,fragment="SWIG_FromCharPtrAndSize") SWIGCDATA {
  %set_output(SWIG_FromCharPtrAndSize($1.data,$1.len));
}

#endif

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
static SWIGCDATA cdata_##TYPE(TYPE *ptr, swig_cdata_nelems_type nelements)
#else
static SWIGCDATA cdata_##NAME(TYPE *ptr, swig_cdata_nelems_type nelements)
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
SWIGCDATA cdata_##TYPE(TYPE *ptr, swig_cdata_nelems_type nelements = 1);
#else
SWIGCDATA cdata_##NAME(TYPE *ptr, swig_cdata_nelems_type nelements = 1);
#endif
%enddef

%rename(cdata) ::cdata_void(void *ptr, swig_cdata_nelems_type nelements = 1);

%cdata(void);

/* Memory move function. Due to multi-argument typemaps this appears to be wrapped as
void memmove(void *data, const char *s); */
void memmove(void *data, const void *indata, size_t inlen);




