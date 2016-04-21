%{
#include <string>
%}

namespace std {

// use "const string &" typemaps for wrapping member strings
%naturalvar string;

class string;

%typemap(ctype) string "char *"
%typemap(ctype) string * "char *"
%typemap(ctype) string & "char *"
%typemap(ctype) const string & "char *"
%typemap(cppouttype, retobj="1") string "std::string*"
%typemap(cppouttype) const string &, string *, string & "std::string*"

%typemap(in) string {
  if ($input) {
    $1.assign($input);
  }
  else {
    $1.resize(0);
  }
}

%typemap(in) const string &, string *, string & {
  if ($input) {
    $1 = new std::string($input);
  }
  else {
    $1 = new std::string();
    $1->resize(0);
  }
}

%typemap(freearg) const string &, string *, string & {
  if ($1)
    delete $1;
}

%typemap(out) string, const string &, string *, string & {
  const char *str = cppresult->c_str();
  size_t len = strlen(str);
  $result = (char *) malloc(len + 1);
  memcpy($result, str, len);
  $result[len] = '\0';
}

}
