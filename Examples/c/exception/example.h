/* File : example.h */

#include <string.h>
#ifndef SWIG
struct A {
};
#define SWIG_THROW(...)
#endif

class Exc {
public:
  Exc(int c, const char *m) {
    code = c;
    strncpy(msg,m,255);
  }
  int code;
  char msg[256];
};

class Test {
public:
  int simple() SWIG_THROW(int&) {
      throw(37);
      return 1;
  }
  int message() SWIG_THROW(const char *) {
      throw("I died.");
      return 1;
  }
  int hosed() SWIG_THROW(Exc) {
      throw(Exc(42,"Hosed"));
      return 1;
  } 
  int unknown() SWIG_THROW(A*) {
      static A a;
      throw &a;
      return 1;
  }
  int multi(int x) SWIG_THROW(int, const char *, Exc) {
     if (x == 1) throw(37);
     if (x == 2) throw("Bleah!");
     if (x == 3) throw(Exc(42,"No-go-diggy-die"));
     return 1;
  }
};
