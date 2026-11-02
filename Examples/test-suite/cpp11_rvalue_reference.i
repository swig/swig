// This testcase checks whether SWIG correctly parses C++11 rvalue references.
%module cpp11_rvalue_reference

// A library argout typemap for the type, such as one writing back an 'int &&', must not be used with an 'in' typemap that takes no input
%typemap(in, numinputs=0) int &&ignored (int temp) "temp = 7; $1 = &temp;"

%inline %{
#include <utility>
class A {
public:
  int  getAcopy() { return _a; }
  int *getAptr()  { return &_a; }
  int &getAref()  { return _a; }
  int &&getAmove() { return std::move(_a); }

  void setAcopy(int a) { _a = a; }
  void setAptr(int *a)  { _a = *a; }
  void setAref(int &a)  { _a = a; }
  void setAmove(int &&a) { _a = a; }
  int takeIgnored(int &&ignored) { return ignored; }

private:
  int _a;
};

// An rvalue reference type-id as the default of a template type parameter
template<class T = int &&> struct RvalueRefDefault {
  T move(int &i) { return std::move(i); }
};
%}

%template(RvalueRefDefault_def) RvalueRefDefault<>;
