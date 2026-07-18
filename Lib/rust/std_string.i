/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

%typemap(ctype, out="char *") string "const char *"
%typemap(imtype, out="*mut c_char") string "*const c_char"
%typemap(rusttype) string "String"

%typemap(in) string
%{ if ($input) {
     $1.assign($input);
   } else {
     $1.clear();
   } %}
%typemap(out) string %{ $result = SWIG_RustStringCopy($1.c_str()); %}

%typemap(rustin, pre="let $rustinput_cstr = std::ffi::CString::new($rustinput).expect(\"string contains interior nul byte\");") string "$rustinput_cstr.as_ptr() as *mut c_char"
%typemap(rustout) string {
let ptr = $imcall;
if ptr.is_null() {
  String::new()
} else {
  let ret = std::ffi::CStr::from_ptr(ptr).to_string_lossy().into_owned();
  Rust_string_free_raw(ptr);
  ret
}
}

%typemap(rustdirectorin) string {
if $iminput.is_null() {
  String::new()
} else {
  unsafe { std::ffi::CStr::from_ptr($iminput).to_string_lossy().into_owned() }
}
}
%typemap(rustdirectorout) string "std::ffi::CString::new($rustcall).expect(\"string contains interior nul byte\").into_raw()"

%typemap(directorin) string %{ $input = (char *)$1.c_str(); %}
%typemap(directorout) string
%{ if ($input) {
     $result.assign($input);
   } else {
     $result.clear();
   } %}
%typemap(throws, canthrow=1) string
%{ SWIG_RustSetPendingException("std::string", $1.c_str());
   return $null; %}

%typemap(ctype, out="char *") const string & "const char *"
%typemap(imtype, out="*mut c_char") const string & "*const c_char"
%typemap(rusttype) const string & "String"

%typemap(in) const string & ($*1_ltype temp)
%{ if ($input) {
     temp.assign($input);
   } else {
     temp.clear();
   }
   $1 = &temp; %}
%typemap(out) const string & %{ $result = SWIG_RustStringCopy($1->c_str()); %}

%typemap(rustin, pre="let $rustinput_cstr = std::ffi::CString::new($rustinput).expect(\"string contains interior nul byte\");") const string & "$rustinput_cstr.as_ptr() as *mut c_char"
%typemap(rustout) const string & {
let ptr = $imcall;
if ptr.is_null() {
  String::new()
} else {
  let ret = std::ffi::CStr::from_ptr(ptr).to_string_lossy().into_owned();
  Rust_string_free_raw(ptr);
  ret
}
}

%typemap(rustdirectorin) const string & {
if $iminput.is_null() {
  String::new()
} else {
  unsafe { std::ffi::CStr::from_ptr($iminput).to_string_lossy().into_owned() }
}
}
%typemap(rustdirectorout) const string & "std::ffi::CString::new($rustcall).expect(\"string contains interior nul byte\").into_raw()"

%typemap(directorin) const string & %{ $input = (char *)$1.c_str(); %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ static $*1_ltype temp;
   if ($input) {
     temp.assign($input);
   } else {
     temp.clear();
   }
   $result = &temp; %}
%typemap(throws, canthrow=1) const string &
%{ SWIG_RustSetPendingException("std::string", $1.c_str());
   return $null; %}

}
