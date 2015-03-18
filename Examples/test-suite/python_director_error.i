%module(directors="1") python_director_error
%insert("director_error")
%{
  exception_count++;
  throw $exception;
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

static int exception_count;

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
