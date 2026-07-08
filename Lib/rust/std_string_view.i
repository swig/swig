/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * Typemaps for std::string_view and const std::string_view&.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
#include <string_view>
%}

namespace std {
%naturalvar string_view;
class string_view {
};
}

%typemap(ctype) string_view "const char *"
%typemap(imtype, out="*mut c_char") string_view "*const c_char"
%typemap(rusttype) string_view "String"
%typemap(in) string_view ($1_ltype temp) %{ temp = std::string_view($input ? $input : ""); $1 = temp; %}
%typemap(out) string_view %{ std::string $1_str($1); $result = SWIG_RustStringCopy($1_str.c_str()); %}
%typemap(rustin, pre="let $rustinput_cstr = std::ffi::CString::new($rustinput).expect(\"string contains interior nul byte\");") string_view "$rustinput_cstr.as_ptr() as *mut c_char"
%typemap(rustout) string_view {
  let ptr = $imcall;
  rust_check_exception();
  let ret = std::ffi::CStr::from_ptr(ptr).to_string_lossy().into_owned();
  libc_free(ptr as *mut c_void);
  ret
}

%typemap(ctype) const string_view & "const char *"
%typemap(imtype, out="*mut c_char") const string_view & "*const c_char"
%typemap(rusttype) const string_view & "String"
%typemap(in) const string_view & ($*1_ltype temp) %{ temp = std::string_view($input ? $input : ""); $1 = &temp; %}
%typemap(out) const string_view & %{ std::string $1_str(*$1); $result = SWIG_RustStringCopy($1_str.c_str()); %}
%typemap(rustin, pre="let $rustinput_cstr = std::ffi::CString::new($rustinput).expect(\"string contains interior nul byte\");") const string_view & "$rustinput_cstr.as_ptr() as *mut c_char"
%typemap(rustout) const string_view & {
  let ptr = $imcall;
  rust_check_exception();
  let ret = std::ffi::CStr::from_ptr(ptr).to_string_lossy().into_owned();
  libc_free(ptr as *mut c_void);
  ret
}

%typemap(ctype) std::string_view "const char *"
%typemap(imtype, out="*mut c_char") std::string_view "*const c_char"
%typemap(rusttype) std::string_view "String"
%typemap(in) std::string_view ($1_ltype temp) %{ temp = std::string_view($input ? $input : ""); $1 = temp; %}
%typemap(out) std::string_view %{ std::string $1_str($1); $result = SWIG_RustStringCopy($1_str.c_str()); %}
%typemap(rustin, pre="let $rustinput_cstr = std::ffi::CString::new($rustinput).expect(\"string contains interior nul byte\");") std::string_view "$rustinput_cstr.as_ptr() as *mut c_char"
%typemap(rustout) std::string_view {
  let ptr = $imcall;
  rust_check_exception();
  let ret = std::ffi::CStr::from_ptr(ptr).to_string_lossy().into_owned();
  libc_free(ptr as *mut c_void);
  ret
}

%typemap(ctype) const std::string_view & "const char *"
%typemap(imtype, out="*mut c_char") const std::string_view & "*const c_char"
%typemap(rusttype) const std::string_view & "String"
%typemap(in) const std::string_view & ($*1_ltype temp) %{ temp = std::string_view($input ? $input : ""); $1 = &temp; %}
%typemap(out) const std::string_view & %{ std::string $1_str(*$1); $result = SWIG_RustStringCopy($1_str.c_str()); %}
%typemap(rustin, pre="let $rustinput_cstr = std::ffi::CString::new($rustinput).expect(\"string contains interior nul byte\");") const std::string_view & "$rustinput_cstr.as_ptr() as *mut c_char"
%typemap(rustout) const std::string_view & {
  let ptr = $imcall;
  rust_check_exception();
  let ret = std::ffi::CStr::from_ptr(ptr).to_string_lossy().into_owned();
  libc_free(ptr as *mut c_void);
  ret
}
