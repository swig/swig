/* -------------------------------------------------------------------------
 * std_string.i
 * ------------------------------------------------------------------------- */

%include <cstring.i>

%fragment("<string>");

/* -------------------------------------------------------------------------
 * TYPEMAPS
 *
 * Optional string typemaps for native fortran conversion.
 *
 * Use:
 *     %apply const std::string& NATIVE { const std::string& key };
 * ------------------------------------------------------------------------- */

// Fortran side treats like regular strings
%apply const char *NATIVE{ const std::string & NATIVE };

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, fragment="SWIG_chararray_to_string_f") const std::string &NATIVE %{
  call SWIG_chararray_to_string($1, $result)
%}

// C input translation typemaps: $1 is std::string*, $input is SwigArrayWrapper
%typemap(in) const std::string &NATIVE (std::string tempstr) %{
  tempstr = std::string(static_cast<const char *>($input->data), $input->size);
  $1 = &tempstr;
%}

// C output translation typemaps: $1 is string*, $input is SwigArrayWrapper
%typemap(out) const std::string &NATIVE %{
  $result.data = ($1->empty() ? NULL : &(*$1->begin()));
  $result.size = $1->size();
%}

// RETURN BY VALUE
%apply const std::string &NATIVE { std::string NATIVE };

%feature("novaluewrapper") std::string;

// Copy the string to a temporary buffer (not null-terminated)
%typemap(out, fragment="<stdlib.h>", fragment="<string.h>") std::string NATIVE %{
  $result.size = $1.size();
  if ($result.size > 0) {
    $result.data = std::malloc($result.size);
    memcpy($result.data, $1.c_str(), $result.size);
  } else {
    $result.data = NULL;
  }
%}

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, fragment="SWIG_chararray_to_string_f",
         fragment="SWIG_free_f") std::string NATIVE %{
  call SWIG_chararray_to_string($1, $result)
  call SWIG_free($1%data)
%}

/* -------------------------------------------------------------------------
 * DEFINITIONS
 * ------------------------------------------------------------------------- */
namespace std {
class string {
public:
  typedef std::size_t size_type;
  typedef char value_type;
  //typedef const char& const_reference;
  typedef const char *const_pointer;
  typedef char *pointer;

public:
  // >>> Construct and assign

  string();
  void resize(size_type count);
  void clear();

  // >>> ACCESS

  size_type size() const;
  size_type length() const;

  %extend {
    %apply const std::string &NATIVE{ const std::string & str };
    // Access as a newly allocated fortran string
    const std::string &str() { return *$self; }
  }
};
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
