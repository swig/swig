// SWIG typemaps for std::string
// copied from the guile std_string.i and modified

%{
#include <string>
%}

namespace std {

    class string;

    %typemap(typecheck) string = char *;
    %typemap(typecheck) const string & = char *;

    %typemap(in) string (char* tempptr) {
      if ($input == C_SCHEME_FALSE) {
	$1 = std::string();
      } else { 
	if (!C_swig_is_string ($input)) {
	  swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, 
		     "Argument #$argnum is not a string");
   	}
	tempptr = SWIG_MakeString($input);
	$1 = std::string(tempptr);
	if (tempptr) SWIG_free(tempptr);
      }
    }

    %typemap(in) const string& (std::string temp,
			 char* tempptr) {

      if ($input == C_SCHEME_FALSE) {
	temp = std::string();
	$1 = &temp;
      } else { 
	if (!C_swig_is_string ($input)) {
	  swig_barf (SWIG_BARF1_BAD_ARGUMENT_TYPE, 
		     "Argument #$argnum is not a string");
	}
	tempptr = SWIG_MakeString($input);
	temp = std::string(tempptr);
	if (tempptr) SWIG_free(tempptr);
	$1 = &temp;
      }
    }

    %typemap(out) string { 
      int size = $1.size();
      C_word *space = C_alloc (C_SIZEOF_STRING (size));
      $result = C_string (&space, size, (char *) $1.c_str());
    }

    %typemap(out) const string& { 
      int size = $1->size();
      C_word *space = C_alloc (C_SIZEOF_STRING (size));
      $result = C_string (&space, size, (char *) $1->c_str());
    }
}
