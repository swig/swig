/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

/* ------------------------------------------------------------
 * Typemap for passing bytes with length
 * ------------------------------------------------------------ */

%typemap(in,checkfn="lua_isstring") (const void *BYTES, size_t LENGTH) {
  size_t len;
  $1 = ($1_ltype)lua_tolstring(L, $input, &len);
  SWIG_contract_assert($1, "non null string");
  $2 = ($2_ltype)len;
}
%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out) SWIGCDATA %{lua_pushlstring(L, $1.data,$1.len); SWIG_arg++;%}

%include <typemaps/cdata_end.swg>
