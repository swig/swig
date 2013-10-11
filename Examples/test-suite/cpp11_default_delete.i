/* This testcase checks whether SWIG correctly parses the default and delete
   keywords which keep or remove default C++ object construction functions. */
%module cpp11_default_delete

%{
#include <stdlib.h>

class NonCopyable {
public:
  NonCopyable& operator=(const NonCopyable&) = delete; /* Removes operator= */
  NonCopyable(const NonCopyable&) = delete; /* Removed copy constructor */
  NonCopyable() = default; /* Explicitly allows the empty constructor */
  void *operator new(size_t) = delete; /* Removes new NonCopyable */
};

struct A1 {
  void f(int i);
  void f(double i) = delete;  /* Don't cast double to int. Compiler returns an error */
};
struct A2 {
  void f(int i);
  template<class T> void f(T) = delete; /* Only accept int */
};
%}
