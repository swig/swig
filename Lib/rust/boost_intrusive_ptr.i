/* -----------------------------------------------------------------------------
 * boost_intrusive_ptr.i
 *
 * boost::intrusive_ptr<T> declarations for Rust.
 * ----------------------------------------------------------------------------- */

namespace boost {
template<class T> class intrusive_ptr {
};
}

%define %intrusive_ptr(TYPE)
%feature("smartptr", noblock=1) TYPE { boost::intrusive_ptr<TYPE > }
%typemap(ctype) boost::intrusive_ptr<TYPE > "void *"
%typemap(imtype, out="*mut c_void") boost::intrusive_ptr<TYPE > "*mut c_void"
%typemap(rusttype) boost::intrusive_ptr<TYPE > "TYPE"
%typemap(in) boost::intrusive_ptr<TYPE > %{ $1 = *($&1_ltype)$input; %}
%typemap(out) boost::intrusive_ptr<TYPE > %{ $result = new $1_ltype($1); %}
%typemap(rustin) boost::intrusive_ptr<TYPE > "$rustinput.as_mut_ptr()"
%typemap(rustout) boost::intrusive_ptr<TYPE > {
  let ptr = $imcall;
  rust_check_exception();
  TYPE::from_raw_owned_unchecked(ptr, true)
}
%enddef
