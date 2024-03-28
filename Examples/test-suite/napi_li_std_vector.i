// Node-API specific implementations
// (with copy-conversion)
%module napi_li_std_vector

%include "std_vector.i"

// Convert all input arguments
%apply(std::vector const &INPUT)      { std::vector const & }
%apply(std::vector INPUT)             { std::vector };

// Convert all return values
%apply(std::vector RETURN)            { std::vector };
%apply(std::vector &RETURN)           { std::vector *, std::vector & };

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


// Special case of a unique_ptr (non-copyable object)
%include <std_unique_ptr.i>
%unique_ptr(Integer);

%inline %{
struct Integer {
  int value;
  Integer(int v): value(v) {};
};
void return_vector_unique_ptr(std::vector<std::unique_ptr<Integer>> &output) {
  output.emplace_back(new Integer(3));
  output.emplace_back(new Integer(5));
  output.emplace_back(new Integer(8));
}
int receive_vector_unique_ptr(const std::vector<std::unique_ptr<Integer>> &input) {
  return input[2]->value;
}
// https://github.com/mmomtchev/swig/issues/47
void return_vector_ptr(std::vector<Integer *> &output) {
  static Integer all_mine(1337);
  output.push_back(&all_mine);
  output.push_back(&all_mine);
  output.push_back(&all_mine);
}
%}

// A very special case that requires special handling
%typemap(out)       const std::vector<std::unique_ptr<Integer>> &return_const_vector_unique {
  Napi::Array array = Napi::Array::New(env, $1->size());
  for (size_t i = 0; i < $1->size(); i++) {
    Napi::Value js_val;
    $typemap(out, std::unique_ptr<Integer> &, 1=(&($1->at(i))), result=js_val, argnum=array value);
    array.Set(i, js_val);
  }
  $result = array;
}
%inline %{
const std::vector<std::unique_ptr<Integer>> &return_const_vector_unique() {
  static std::vector<std::unique_ptr<Integer>> const_vector;
  if (const_vector.size() == 0) {
    const_vector.emplace_back(new Integer(3));
    const_vector.emplace_back(new Integer(5));
    const_vector.emplace_back(new Integer(8));
  }
  return const_vector;
}
%}
