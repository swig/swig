/*
  Deques
*/

%ignore std::deque::push_back;
%ignore std::deque::pop_back;

#define %swig_deque_methods(Type...) %swig_sequence_methods(Type)
#define %swig_deque_methods_val(Type...) %swig_sequence_methods_val(Type);

%include <std/std_deque.i>
