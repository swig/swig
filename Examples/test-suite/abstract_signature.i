%module abstract_signature

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) abstract_foo;	// Ruby, wrong class name
%warnfilter(SWIGWARN_RUBY_WRONG_NAME) abstract_bar;	// Ruby, wrong class name
%warnfilter(SWIGWARN_LANG_OVERLOAD_SHADOW) meth; // Fortran prevents overloaded methods from overriding a base class non-overloaded method

%inline %{ 
class abstract_foo 
{ 
public: 
  abstract_foo() { }
  virtual ~abstract_foo() { }
  virtual int   meth(int meth_param) = 0; 
}; 
 
 
class abstract_bar : public abstract_foo 
{ 
public: 
  abstract_bar() { }
 
  virtual ~abstract_bar() { }
  virtual int   meth(int meth_param) = 0; 
  int           meth(int meth_param_1, int meth_param_2) { return 0; }
}; 

%}
