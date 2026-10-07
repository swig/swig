/* -----------------------------------------------------------------------------
 * std_string_view.i
 *
 * std::string_view typemaps for Guile
 * ----------------------------------------------------------------------------- */

%{
#include <string>
#include <string_view>
%}

namespace std {

  %naturalvar string_view;

  %typemap(in) string_view (char *$1_ptr) {
    size_t $1_len;
    $1_ptr = scm_to_utf8_stringn($input, &$1_len);
    $1 = std::string_view($1_ptr, $1_len);
  }

  %typemap(freearg) string_view %{
    SWIG_free($1_ptr);
  %}

  %typemap(out) string_view %{
    $result = scm_from_utf8_stringn($1.data(), $1.size());
  %}

  %typemap(in) const string_view& (char *$1_ptr, $*1_ltype view) {
    size_t $1_len;
    $1_ptr = scm_to_utf8_stringn($input, &$1_len);
    view = std::string_view($1_ptr, $1_len);
    $1 = &view;
  }

  %typemap(out) const string_view& %{
    $result = scm_from_utf8_stringn($1->data(), $1->size());
  %}

  %typemap(varout) string_view %{
    $result = scm_from_utf8_stringn($1.data(), $1.size());
  %}

  // for throwing of any kind of string_view, string_view ref's and
  // string_view pointers we convert all to Guile strings
  %typemap(throws) string_view, string_view&, const string_view& %{
    scm_throw(scm_from_locale_symbol("swig-exception"),
              scm_list_1(scm_from_utf8_stringn($1.data(), $1.size())));
  %}

  %typemap(throws) string_view*, const string_view* %{
    scm_throw(scm_from_locale_symbol("swig-exception"),
              scm_list_1(scm_from_utf8_stringn($1->data(), $1->size())));
  %}

  %typemap(typecheck,precedence=SWIG_TYPECHECK_STRINGVIEW) string_view, const string_view& {
    $1 = scm_is_string($input);
  }

  class string_view;

}
