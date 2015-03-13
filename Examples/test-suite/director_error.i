%module(directors="1") director_error

%insert("begin")
%{
static int exception_count;

#define SWIG_DIRECTOR_THROW(e) \
  do { \
    exception_count++; \
    throw (e); \
  } while(false)
%}


%exception {
  try { $action }
  catch (Swig::DirectorException &e) { SWIG_fail; }
}

%{
#include <string>

class Foo {
public:
  virtual void go() = 0;
  virtual ~Foo() {};
};

int GetExceptionCount() {
  return exception_count;
}

void CallGo(Foo *foo) {
  foo->go();
}

%}

%feature("director") Foo;

class Foo {
public:
  virtual ~Foo();
  virtual void go() = 0;
};

int GetExceptionCount();
void CallGo(Foo *foo);
