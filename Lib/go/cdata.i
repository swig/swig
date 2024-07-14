/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%typemap(gotype) (const void *BYTES, size_t LENGTH) "[]byte"
%typemap(in) (const void *BYTES, size_t LENGTH) %{
  $1 = ($1_ltype)$input.array;
  $2 = ($2_ltype)$input.len;
%}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%fragment("cdata", "header") %{
struct swigcdata {
  uintgo size;
  void *data;
};
%}

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

%typemap(goout) SWIGCDATA {
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

%include <typemaps/cdata_end.swg>
