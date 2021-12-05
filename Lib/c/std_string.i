%{
#include <string>
%}

%fragment("SwigStrInOut", "header") {
class SwigStrInOut {
  std::string str_;
  char* ptr_;
  size_t len_;
public:
  void init(char* ptr) {
    ptr_ = ptr;
    if (ptr_) {
      str_ = ptr_;
      len_ = str_.length();
    }
  }

  std::string* str() { return &str_; }

  ~SwigStrInOut() {
    if (ptr_) {
      memcpy(ptr_, str_.c_str(), len_);
      ptr_[len_] = '\0';
    }
  }
};
}

namespace std {

// use "const string &" typemaps for wrapping member strings
%naturalvar string;

class string;

%typemap(ctype) string, const string & "const char *"
%typemap(ctype) string * "char *"
%typemap(ctype) string & "char *"

%typemap(in) string %{
  if ($input)
    $1 = $input;
%}

%typemap(in) const string & (std::string temp) %{
  if ($input)
    temp = $input;
  $1 = &temp;
%}

%typemap(in, fragment="SwigStrInOut") string * (SwigStrInOut temp), string & (SwigStrInOut temp) %{
  temp.init($input);
  $1 = temp.str();
%}

// Note that we don't support strings with embedded NULs, as there is no way to
// return their length to C code anyhow.
%typemap(out) string %{
  $result = strdup(cppresult.c_str());
%}

%typemap(out) const string &, string *, string & %{
  $result = strdup(cppresult->c_str());
%}

}
