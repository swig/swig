%module cpp11_std_function

// function is a reserved keyword in many languages
%rename(_cpp_function) function;

%include <std_string.i>

%{
  #include <functional>
  #include <string>
%}

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

%template(call_function) _SWIG_call_std_function<std::string, int, const std::string &>;
