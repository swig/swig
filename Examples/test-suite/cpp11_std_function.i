%module cpp11_std_function

// function is a reserved word in many languages
%warnfilter(SWIGWARN_PARSE_KEYWORD);

%header %{
#include <functional>
#include <string>
#include <stdexcept>
%}

%include <std_string.i>
%include <std/std_function.i>
%include <exception.i>

%exception {
    try {
        $action
    } catch (const std::exception& e) {
      SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

%rename(cpp_function_string_int_const_string) std::function<std::string(int, const std::string &)>;

%inline %{
std::function<std::string(int, const std::string &)> return_function(int ask_for_pass) {
  return [ask_for_pass](int passcode, const std::string &name) -> std::string {
    if (passcode == ask_for_pass) {
      return name + " passed the test";
    }
    throw std::runtime_error{"Test failed"};
  };
}
%}

%template(cpp_function_string_int_const_string) std::function<std::string(int, const std::string &)>;
%template(call_function) _SWIG_call_std_function<std::string, int, const std::string &>;
