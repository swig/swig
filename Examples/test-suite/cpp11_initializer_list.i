/* This testcase shows a few simple ways to deal with the new initializer_list
   introduced in C++11. */
%module cpp11_initializer_list

%warnfilter(SWIGWARN_TYPEMAP_INITIALIZER_LIST) B::B;
%ignore A::A(std::initializer_list<int>);
%ignore B::method;

%typemap(in) std::initializer_list<const char *> %{
  $1 = {"Ab", "Fab"};
%}

%begin %{
#if __GNUC__ >= 9
/* warning: ‘new’ of initializer_list does not extend the lifetime of the underlying array [-Winit-list-lifetime] */
/* incorrect warning for C::C(std::initializer_list<const char *>) */
#pragma GCC diagnostic ignored "-Winit-list-lifetime"
#endif
%}

%inline %{
#include <initializer_list>
#include <string>

class A {
public:
  A(std::initializer_list<int>) {}
  A() {}
  A(double d) {}
};
class B {
public:
  B(std::initializer_list<int>, std::initializer_list<double>) {}
  B() {}
  void method(std::initializer_list<int> init) {}
};
class C {
  std::string joined;
public:
  C(std::initializer_list<const char *> init) {
    for (auto& val : init)
      joined += val;
  }
  C() {}
  const char * get_joined_string() {
    return joined.c_str();
  }
};
%}

