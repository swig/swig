/* -----------------------------------------------------------------------------
 * swiginterface.i
 *
 * Interface feature placeholders for Rust.
 * ----------------------------------------------------------------------------- */

%define RUST_INTERFACE_TYPEMAPS(CTYPE...)
%typemap(rusttype) CTYPE, CTYPE *, CTYPE [], CTYPE &, CTYPE *const& "*mut c_void"
%typemap(rustin) CTYPE, CTYPE *, CTYPE [], CTYPE &, CTYPE *const& "$rustinput"
%enddef

%define %interface(CTYPE...)
%feature("interface", name="%sSwigInterface") CTYPE;
RUST_INTERFACE_TYPEMAPS(CTYPE)
%enddef

%define %interface_impl(CTYPE...)
%rename("%sSwigImpl") CTYPE;
%feature("interface", name="%(rstrip:[SwigImpl])s") CTYPE;
RUST_INTERFACE_TYPEMAPS(CTYPE)
%enddef

%define %interface_custom(PROXY, INTERFACE, CTYPE...)
%rename(PROXY) CTYPE;
%feature("interface", name=INTERFACE) CTYPE;
RUST_INTERFACE_TYPEMAPS(CTYPE)
%enddef
