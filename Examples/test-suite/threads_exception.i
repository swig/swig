// Throw a lot of exceptions

// The Python runtime tests were previously failing with the -threads option on Windows due to SWIG_PYTHON_THREAD_BEGIN_ALLOW not being within the try block.

%module(threads="1") threads_exception

// throw is invalid in C++17 and later, only SWIG to use it
#define TESTCASE_THROW1(T1) throw(T1)
#define TESTCASE_THROW3(T1, T2, T3) throw(T1, T2, T3)
%{
#define TESTCASE_THROW1(T1)
#define TESTCASE_THROW3(T1, T2, T3)
%}

%{
#include <string.h>
struct A {};
%}

%inline %{
#include <string>

class Exc {
public:
  Exc(int c, const char *m) {
    code = c;
    strncpy(msg,m,255);
    msg[255] = 0;
  }
  int code;
  char msg[256];
};

class Test {
public:
  int simple() TESTCASE_THROW1(int) {
      throw(37);
      return 1;
  }
  int message() TESTCASE_THROW1(const char *) {
      throw("I died.");
      return 1;
  }
  int hosed() TESTCASE_THROW1(Exc) {
      throw(Exc(42,"Hosed"));
      return 1;
  } 
  int unknown() TESTCASE_THROW1(A*) {
      static A a;
      throw &a;
      return 1;
  }
  int multi(int x) TESTCASE_THROW3(int, const char *, Exc) {
     if (x == 1) throw(37);
     if (x == 2) throw("Bleah!");
     if (x == 3) throw(Exc(42,"No-go-diggy-die"));
     return 1;
  }
};

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
