// Node-API specific implementations
// (with copy-conversion)
%module napi_li_std_vector

%include "std_vector.i"

// Convert all input arguments
%apply(std::vector const &INPUT)      { std::vector const & }
%apply(std::vector INPUT)             { std::vector };

// Convert all return values
%apply(std::vector RETURN)            { std::vector };
%apply(std::vector *RETURN)           { std::vector *, std::vector & };

// Convert "*output" and "&output" to return values
%apply(std::vector &OUTPUT)           { std::vector &output, std::vector *output };

%include "li_std_vector.i"

// Additional case, return vector in an argument
void return_vector_in_arg_ref(std::vector<int> &output);
void return_vector_in_arg_ptr(std::vector<int> *output);

%{
void return_vector_in_arg_ref(std::vector<int> &output) {
  output = { 3, 5, 8 };
}
void return_vector_in_arg_ptr(std::vector<int> *output) {
  *output = { 3, 5, 8 };
}
%}
