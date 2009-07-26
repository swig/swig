%include <std_common.i>

%{
  #include <string>
%}

namespace std {

  class string;

  /* Reference documentation: Section 18.4.3 of
   * http://caml.inria.fr/pub/docs/manual-ocaml/manual032.html
   *
   * String_val(v) returns a pointer to the first byte of the string v,
   * with type char *. This pointer is a valid C string: there is a null
   * character after the last character in the string. However, Caml
   * strings can contain embedded null characters, that will confuse the
   * usual C functions over strings.
   */

  %typemap(ocamlin) string "string"
  %typemap(in) string
  %{$1.assign(String_val($input), caml_string_length($input));%}

  %typemap(ocamlin) const string & "string"
  %typemap(in) const string &
  {
    std::string $1_str(String_val($input), caml_string_length($input));
    $1 = &$1_str;
  }

}
