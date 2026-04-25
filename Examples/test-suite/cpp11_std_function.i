%module cpp11_std_function

%header %{
#include <functional>
#include <string>
#include <stdexcept>
%}

%include <std_string.i>
%include <std_function.i>
%include <exception.i>

%exception {
    try {
        $action
    } catch (const std::exception& e) {
      SWIG_exception(SWIG_RuntimeError, e.what());
    }
}

// function is a reserved word in many languages
// These languages attempt to rename any symbol called function, which overrides the %template name
#if defined(SWIGD) || defined(SWIGJAVASCRIPT) || defined(SWIGLUA) || defined(SWIGPHP) || defined(SWIGR)
//%warnfilter(SWIGWARN_PARSE_KEYWORD) std::function<std::string(int, const std::string &)>;
// %rename(cpp_function_string_int_const_string) std::function<std::string(int, const std::string &)>;
%rename(cpp_function_string_int_const_string) function;
#endif

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
%template(call_function) SWIG_call_std_function<std::string, int, const std::string &>;
