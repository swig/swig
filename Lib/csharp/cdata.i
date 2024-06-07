/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%pragma(csharp) imclasscode=%{
  [global::System.Runtime.InteropServices.DllImport("$module", EntryPoint="SWIG_csharp_bytes_to_c")]
  public static extern global::System.IntPtr SWIG_csharp_bytes_to_c0(int len, byte[] ptr);
  public static global::System.IntPtr SWIG_csharp_bytes_to_c(byte[] ptr) {
    return SWIG_csharp_bytes_to_c0(ptr.Length, ptr);
  }
%}

%fragment("SWIG_csharp_bytes", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
typedef struct { int len; void *ptr; } SWIG_csharp_bytes;

SWIGEXPORT void *SWIGSTDCALL SWIG_csharp_bytes_to_c(int len, void *ptr) {
  SWIG_csharp_bytes *ret = (SWIG_csharp_bytes *)malloc(sizeof(SWIG_csharp_bytes));
  if (ret == SWIG_NULLPTR) {
    SWIG_CSharpSetPendingException(SWIG_CSharpOutOfMemoryException, "fail to duplicate bytes container.");
    return SWIG_NULLPTR;
  }
  if (len > 0) {
    ret->ptr = malloc(len);
    if (ret->ptr == SWIG_NULLPTR) {
      SWIG_CSharpSetPendingException(SWIG_CSharpOutOfMemoryException, "fail to duplicate bytes.");
      free(ret);
      return SWIG_NULLPTR;
    }
    memcpy(ret->ptr, ptr, len);
    ret->len = len;
  } else {
    ret->ptr = SWIG_NULLPTR;
    ret->len = 0;
  }
  return ret;
}

#ifdef __cplusplus
}
#endif
%}

%typemap(cstype) (const void *BYTES, size_t LENGTH) "byte[]"
%typemap(ctype)  (const void *BYTES, size_t LENGTH) "void *"
%typemap(imtype) (const void *BYTES, size_t LENGTH) "global::System.IntPtr"
%typemap(csin)   (const void *BYTES, size_t LENGTH) "$modulePINVOKE.SWIG_csharp_bytes_to_c($csinput)"
%typemap(in, canthrow=1, fragment="SWIG_csharp_bytes") (const void *BYTES, size_t LENGTH) {
  SWIG_csharp_bytes *p = (SWIG_csharp_bytes *)$input;
  if (p != SWIG_NULLPTR) {
    $1 = ($1_ltype)p->ptr;
    $2 = ($2_ltype)p->len;
  } else {
    $1 = 0;
    $2 = 0;
  }
}
%typemap(freearg, fragment="SWIG_csharp_bytes") (const void *BYTES, size_t LENGTH) {
  SWIG_csharp_bytes *p = (SWIG_csharp_bytes *)$input;
  if (p != SWIG_NULLPTR) {
    free(p->ptr);
    free(p);
  }
}

%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%pragma(csharp) imclasscode=%{
  [global::System.Runtime.InteropServices.DllImport("$module", EntryPoint="SWIG_csharp_data")]
  public static extern int SWIG_csharp_data(global::System.IntPtr data, ref global::System.IntPtr m);
%}

%fragment("SWIG_csharp_data", "header") %{
#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORT int SWIGSTDCALL SWIG_csharp_data(SWIGCDATA *d, void **ptr) {
  int ret = 0;
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

%typemap(ctype) SWIGCDATA "SWIGCDATA *"
%typemap(imtype) SWIGCDATA "global::System.IntPtr"
%typemap(cstype) SWIGCDATA "byte[]"
%typemap(out) SWIGCDATA %{
  $result = (SWIGCDATA*)malloc(sizeof($1));
  if ($result != SWIG_NULLPTR) {
    memcpy($result, &$1, sizeof($1));
  }
%}
%typemap(csout, fragment="SWIG_csharp_data") SWIGCDATA {
  global::System.IntPtr mm = global::System.IntPtr.Zero;
  int size = $modulePINVOKE.SWIG_csharp_data($imcall, ref mm);
  byte[] ret = new byte[size];
  if (size > 0) {
    System.Runtime.InteropServices.Marshal.Copy(mm, ret, 0, size);
  }
  return ret;
}

%include <typemaps/cdata_end.swg>
