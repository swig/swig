/* -----------------------------------------------------------------------------
 * wchar.i
 *
 * wchar_t typemaps for Rust.
 * ----------------------------------------------------------------------------- */

%typemap(ctype) wchar_t, const wchar_t & "wchar_t"
%typemap(imtype) wchar_t, const wchar_t & "u32"
%typemap(rusttype) wchar_t, const wchar_t & "u32"
%typemap(in) wchar_t %{ $1 = (wchar_t)$input; %}
%typemap(in) const wchar_t & ($*1_ltype temp) %{ temp = (wchar_t)$input; $1 = &temp; %}
%typemap(out) wchar_t %{ $result = (unsigned int)$1; %}
%typemap(out) const wchar_t & %{ $result = (unsigned int)*$1; %}
%typemap(rustin) wchar_t, const wchar_t & "$rustinput"
%typemap(rustout) wchar_t, const wchar_t & "$imcall"
