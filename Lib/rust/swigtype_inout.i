/* -----------------------------------------------------------------------------
 * swigtype_inout.i
 *
 * SWIGTYPE pointer in/out typemaps for Rust.
 * ----------------------------------------------------------------------------- */

%typemap(ctype) SWIGTYPE *& OUTPUT "void **"
%typemap(imtype) SWIGTYPE *& OUTPUT "*mut *mut c_void"
%typemap(rusttype) SWIGTYPE *& OUTPUT "*mut *mut c_void"
%typemap(in) SWIGTYPE *& OUTPUT
%{ $1 = ($1_ltype)$input; %}
%typemap(rustin) SWIGTYPE *& OUTPUT "$rustinput"
%typemap(rustout) SWIGTYPE *& OUTPUT "$imcall"

%typemap(ctype) SWIGTYPE *& INOUT "void **"
%typemap(imtype) SWIGTYPE *& INOUT "*mut *mut c_void"
%typemap(rusttype) SWIGTYPE *& INOUT "*mut *mut c_void"
%typemap(in) SWIGTYPE *& INOUT
%{ $1 = ($1_ltype)$input; %}
%typemap(rustin) SWIGTYPE *& INOUT "$rustinput"
%typemap(rustout) SWIGTYPE *& INOUT "$imcall"
