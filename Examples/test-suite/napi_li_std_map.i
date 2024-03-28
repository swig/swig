// Node-API specific implementations
// (with copy-conversion)
%module napi_li_std_map

/* --- std::map --- */
%include "std_map.i"

// for valueAverage & stringifyKeys
%apply(std::map INPUT)               { std::map m };

// for populate
%apply(std::map &OUTPUT)             { std::map &m };

%include "li_std_map.i"

// https://github.com/mmomtchev/swig/issues/44
%typemap(out) std::map<std::string, bool> = std::map RETURN;
%inline {
std::map<std::string, bool> return_map() {
  return { {"a", true}, {"b", false} };
}
}

// https://github.com/mmomtchev/swig/issues/43
%typemap(out) std::map<std::string, std::map<std::string, bool>> = std::map RETURN;
%inline {
std::map<std::string, std::map<std::string, bool>> return_map_map() {
  return { {"map", { {"a", true}, {"b", false} } } };
}
}

// Special case of a unique_ptr (non-copyable object)
%include <std_unique_ptr.i>
%unique_ptr(Integer);
%apply(std::map &OUTPUT)              { std::map &output };
%apply(const std::map &INPUT)         { const std::map &input };

%inline %{
struct Integer {
  int value;
  Integer(int v): value(v) {};
};
void return_map_unique_ptr(std::map<std::string, std::unique_ptr<Integer>> &output) {
  output.emplace("answer", new Integer(42));
}
int receive_map_unique_ptr(const std::map<std::string, std::unique_ptr<Integer>> &input) {
  return input.at("answer")->value;
}
%}
