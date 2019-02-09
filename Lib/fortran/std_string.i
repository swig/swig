/* -------------------------------------------------------------------------
 * std_string.i
 *
 * This header file simply applies native Fortran character string wrapping to
 * the std::string class. Strings are returned as
 *   character(kind=C_CHAR, len=:), allocatable
 * and input as
 *   character(kind=C_CHAR, len=*)
 *
 * ------------------------------------------------------------------------- */

%include <fortranstrings.swg>

// Include std::string header
%fragment("<string>");

/* -------------------------------------------------------------------------
 * STD::STRING TYPEMAPS
 *
 * Typemaps for native fortran string conversion.
 * ------------------------------------------------------------------------- */

%naturalvar string;

/* Note that this is technically incorrect: string is typedef'd as
 * basic_string<char,...> . Our definition in std_string.i is simpler, though,
 * because that's all we need to inform SWIG.
 */
namespace std {
class string;
}

/* ---- CONST REFERENCE: NATIVE STRING ---- */

// Fortran treats like C strings
%apply const char * {const std::string &};

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, noblock=1, fragment="SWIG_chararray_to_string_f") const std::string & {
  call SWIG_chararray_to_string($1, $result)
}

// C input translation typemaps: $1 is std::string*, $input is SwigArrayWrapper
%typemap(in, noblock=1) const std::string & (std::string tempstr) {
  tempstr = std::string(static_cast<const char *>($input->data), $input->size);
  $1 = &tempstr;
}

// C output translation typemaps: $1 is string*, $input is SwigArrayWrapper
%typemap(out, noblock=1) const std::string & {
  $result.data = ($1->empty() ? NULL : &(*$1->begin()));
  $result.size = $1->size();
}

/* ---- VALUE: NATIVE STRING ---- */

%apply const std::string & { std::string };

%typemap(globalin) std::string {
   $1 = *$input;
}
%typemap(memberin) std::string {
   $1 = *$input;
}

// Copy input data to local string
%typemap(in, noblock=1) std::string {
  $1.assign(static_cast<const char *>($input->data), $input->size);
}

// Copy the string to a temporary buffer (not null-terminated)
%typemap(out, noblock=1, fragment="<stdlib.h>", fragment="<string.h>") std::string {
  $result.size = $1.size();
  if ($result.size > 0) {
    $result.data = malloc($result.size);
    memcpy($result.data, $1.c_str(), $result.size);
  } else {
    $result.data = NULL;
  }
}

// Fortran proxy translation code: convert from char array to Fortran string
%typemap(fout, noblock=1, fragment="SWIG_chararray_to_string_f",
         fragment="SWIG_free_f") std::string {
  call SWIG_chararray_to_string($1, $result)
  call SWIG_free($1%data)
}

