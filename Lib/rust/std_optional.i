/* -----------------------------------------------------------------------------
 * std_optional.i
 *
 * std::optional<T> typemaps for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <optional>
%}

%define %optional(TYPE...)
%typemap(ctype) std::optional<TYPE > "void *"
%typemap(imtype, out="*mut c_void") std::optional<TYPE > "*mut c_void"
%typemap(rusttype) std::optional<TYPE > "Option<TYPE>"
%typemap(in) std::optional<TYPE > (TYPE *argp = 0) %{
  argp = (TYPE *)$input;
  if (argp) {
    $1 = *argp;
    delete argp;
  } else {
    $1 = std::nullopt;
  }
%}
%typemap(out) std::optional<TYPE > %{
  std::optional<TYPE > swig_optional_result = $1;
  $result = swig_optional_result ? (void *)new TYPE(*swig_optional_result) : 0;
%}
%typemap(rustin) std::optional<TYPE > "$rustinput.map_or(std::ptr::null_mut(), |value| value.into_raw())"
%typemap(rustout) std::optional<TYPE > {
  let ptr = $imcall;
  rust_check_exception();
  if ptr.is_null() {
    None
  } else {
    Some(TYPE::from_raw_owned_unchecked(ptr, true))
  }
}
%enddef
