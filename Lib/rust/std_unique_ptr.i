/* -----------------------------------------------------------------------------
 * std_unique_ptr.i
 *
 * std::unique_ptr<T> typemaps for Rust.
 * ----------------------------------------------------------------------------- */

%include <unique_ptr.swg>

%define %unique_ptr(TYPE...)
%typemap(ctype) std::unique_ptr<TYPE >, std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && "void *"
%typemap(imtype, out="*mut c_void") std::unique_ptr<TYPE >, std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && "*mut c_void"
%typemap(rusttype) std::unique_ptr<TYPE >, std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && "TYPE"
%typemap(in) std::unique_ptr<TYPE > %{ $1.reset((TYPE *)$input); %}
%typemap(in) std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && %{
  $*1_ltype $1_uptr((TYPE *)$input);
  $1 = &$1_uptr;
%}
%typemap(in, fragment="SwigNoDeleteUniquePtr") const std::unique_ptr<TYPE > & %{
  swig::NoDeleteUniquePtr<TYPE > $1_ndup((TYPE *)$input);
  $1 = &$1_ndup.uptr;
%}
%typemap(out) std::unique_ptr<TYPE > %{ $result = (void *)$1.release(); %}
%typemap(out) std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && %{ $result = (void *)$1->get(); %}
%typemap(rustin) std::unique_ptr<TYPE >, std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && "$rustinput.into_raw()"
%typemap(rustin) const std::unique_ptr<TYPE > & "$rustinput.as_mut_ptr()"
%typemap(rustout) std::unique_ptr<TYPE > {
  let ptr = $imcall;
  rust_check_exception();
  TYPE::from_raw_owned_unchecked(ptr, true)
}
%typemap(rustout) std::unique_ptr<TYPE > &, std::unique_ptr<TYPE > && {
  let ptr = $imcall;
  rust_check_exception();
  TYPE::from_raw_owned_unchecked(ptr, false)
}
%template() std::unique_ptr<TYPE >;
%enddef
