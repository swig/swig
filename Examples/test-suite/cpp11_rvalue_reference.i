// This testcase checks whether SWIG correctly parses C++11 rvalue references.
%module cpp11_rvalue_reference

#if defined SWIGGO
// Several: Warning 507: No Go typemap defined for int &&
# pragma SWIG nowarn=SWIGWARN_LANG_NATIVE_UNIMPL
#endif

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

private:
  int _a;
};
%}
