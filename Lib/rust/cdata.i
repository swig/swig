/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

%fragment("SWIG_RustBytes", "header") %{
typedef struct {
  size_t len;
  const void *ptr;
} SWIG_RustBytes;
%}

%pragma(rust) modulecode=%{
#[repr(C)]
#[derive(Clone, Copy)]
pub struct RustBytes {
  pub len: usize,
  pub ptr: *const c_void,
}
%}

%typemap(ctype, fragment="SWIG_RustBytes") (const void *BYTES, size_t LENGTH) "SWIG_RustBytes"
%typemap(imtype) (const void *BYTES, size_t LENGTH) "RustBytes"
%typemap(rusttype) (const void *BYTES, size_t LENGTH) "&[u8]"
%typemap(rustin) (const void *BYTES, size_t LENGTH) "RustBytes { len: $rustinput.len(), ptr: $rustinput.as_ptr() as *const c_void }"
%typemap(in) (const void *BYTES, size_t LENGTH) {
  $1 = ($1_ltype)$input.ptr;
  $2 = ($2_ltype)$input.len;
}

%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%fragment("SWIG_RustData", "header") %{
#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORT int SWIGSTDCALL SWIG_rust_data(SWIGCDATA *d, void **ptr) {
  int ret = 0;
  if (d) {
    if (d->len > 0 && d->data) {
      *ptr = (void *)d->data;
      ret = (int)d->len;
    }
    free(d);
  }
  return ret;
}

#ifdef __cplusplus
}
#endif
%}

%pragma(rust) externcode=%{
  pub fn SWIG_rust_data(data: *mut SWIGCDATA, ptr: *mut *mut c_void) -> c_int;
%}

%pragma(rust) modulecode=%{
#[repr(C)]
pub struct SWIGCDATA {
  pub data: *mut c_char,
  pub len: usize,
}
%}

%typemap(ctype) SWIGCDATA "SWIGCDATA *"
%typemap(imtype) SWIGCDATA "*mut SWIGCDATA"
%typemap(rusttype) SWIGCDATA "Vec<u8>"
%typemap(out) SWIGCDATA %{
  $result = (SWIGCDATA *)malloc(sizeof($1));
  if ($result) {
    memcpy($result, &$1, sizeof($1));
  }
%}
%typemap(rustout, fragment="SWIG_RustData") SWIGCDATA {
  let data = $imcall;
  rust_check_exception();
  let mut ptr: *mut c_void = std::ptr::null_mut();
  let size = SWIG_rust_data(data, &mut ptr);
  if size <= 0 || ptr.is_null() {
    Vec::new()
  } else {
    std::slice::from_raw_parts(ptr as *const u8, size as usize).to_vec()
  }
}

%include <typemaps/cdata_end.swg>
