//
// SWIG typemaps for std::string
// Lyle Johnson
// May 1, 2003
//
// Pike implementation

%{
#include <string>
%}

namespace std {

    class string;

    /* Overloading check */

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in, pikedesc="tStr") string {
      if ($input.type != T_STRING)
	Pike_error("Bad argument: Expected a string.\n");
      $1 = std::string(STR0($input.u.string));
    }

    %typemap(in, pikedesc="tStr") const string & (std::string temp) {
      if ($input.type != T_STRING)
	Pike_error("Bad argument: Expected a string.\n");
      temp = std::string(STR0($input.u.string));
      $1 = &temp;
    }

    %typemap(out, pikedesc="tStr") string "push_text($1.c_str());";

    %typemap(out, pikedesc="tStr") const string & "push_text($1->c_str());";
    
    %typemap(inv) string, const string &, string & "$1_name.c_str()";

    %typemap(inv) string *, const string * "$1_name->c_str()";
    
    %typemap(outv) string {
      if ($input.type == T_STRING)
	$result = std::string(STR0($input.u.string));
      else
	throw SWIG_DIRECTOR_TYPE_MISMATCH("string expected");
    }
    
    %typemap(outv) const string & (std::string temp) {
      if ($input.type == T_STRING) {
	temp = std::string(STR0($input.u.string));
	$result = &temp;
      } else {
	throw SWIG_DIRECTOR_TYPE_MISMATCH("string expected");
      }
    }

}

