/* This testcase checks that 'this' is accepted in a default member initializer - SWIG returns a keyword
   token for 'this' in C++, so the expression grammar has to accept it there too. */
%module cpp11_this_member_initializer

%inline %{
struct Node {
  int value = 1;
  Node *parent = this;
  const Node *owner = this;
  int *value_ptr = &this->value;

  int deref() { return *value_ptr; }
  bool is_self_parent() { return parent == this; }
};
%}
