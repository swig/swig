%module abstract_signature

%warnfilter(801) abstract_foo;	// Ruby, wrong class name
%warnfilter(801) abstract_bar;	// Ruby, wrong class name

%inline %{ 
class abstract_foo 
{ 
public: 
  abstract_foo() { }; 
  virtual ~abstract_foo() { }; 
  virtual int   meth(int meth_param) = 0; 
}; 
 
 
class abstract_bar : public abstract_foo 
{ 
public: 
  abstract_bar() { }; 
 
  virtual ~abstract_bar() { }; 
  int           meth(int meth_param_1, int meth_param_2) { return 0; }
}; 

%}
