// Node-API specific implementations
// (with copy-conversion)
%module napi_li_std_pair

%include <std_pair.i>

// Convert all input arguments
%apply(std::pair const &INPUT)      { std::pair const &, std::pair * };
%apply(std::pair INPUT)             { std::pair };

// Convert all return values
%apply(std::pair RETURN)            { std::pair };
%apply(std::pair *RETURN)           { std::pair *, std::pair & };

%include "li_std_pair.i"

// Convert "*output" and "&output" to return values
%clear std::pair *;
%apply(std::pair &OUTPUT)           { std::pair &output, std::pair *output };

// Additional case, return pair in an argument
void return_pair_in_arg_ref(std::pair<int, bool> &output);
void return_pair_in_arg_ptr(std::pair<int, bool> *output);

%{
void return_pair_in_arg_ref(std::pair<int, bool> &output) {
  output = { 2005, true };
}
void return_pair_in_arg_ptr(std::pair<int, bool> *output) {
  *output = { 2005, false };
}
%}

// Special case of a unique_ptr (non-copyable object)
%include <std_unique_ptr.i>
%include <std_string.i>
%unique_ptr(Integer);

%inline %{
struct Integer {
  int value;
  Integer(int v): value(v) {};
};
void return_pair_unique_ptr(std::pair<std::string, std::unique_ptr<Integer>> &output) {
  output.first = "answer";
  output.second = std::unique_ptr<Integer>(new Integer(42));
}
int receive_pair_unique_ptr(const std::pair<std::string, std::unique_ptr<Integer>> &input) {
  return input.second->value;
}
%}
