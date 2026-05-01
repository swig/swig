%module cpp11_std_function

%header %{
#include <functional>
#include <string>
#include <stdexcept>
%}

%include <std_string.i>
%include <std_function.i>
%include <exception.i>

%inline %{
std::function<bool(int, const std::string &)> pass_checker(int pass) {
  return [pass](int passcode, const std::string &name) -> bool {
    return passcode == pass && name == "Petka";
  };
}
%}

%template(cpp_lambda) std::function<bool(int, const std::string &)>;


// Expose a wrapper function to call the functor
%inline %{
template <typename RET, typename... ARGS>
RET call_std_function(std::function<RET(ARGS...)> fn, ARGS ...args) {
  return fn(args...);
}
%}

%template(call_function) call_std_function<bool, int, const std::string &>;
