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
