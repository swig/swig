%module(directors="1") ruby_director

%{
#include <iostream>

class ShouldBeDestroyed {
public:
  ShouldBeDestroyed() {
    std::cout << "constructed." << std::endl;
  }

  ~ShouldBeDestroyed() {
    std::cout << "yes destroyed." << std::endl;
  }
};

class Base {
public:
  Base() : m(1) {}
  Base(int i) : m(i) {}
  virtual ~Base() {}
  virtual int ret_m() { return m; };
private:
  int m;
};

int call_ret_m(Base *b) {
  ShouldBeDestroyed s;
  return b->ret_m();
}

%}
%feature("director:except") {
  throw Swig::DirectorMethodException($error);
}
%exception {
  try { $action }
  catch (Swig::DirectorException &e) { rb_exc_raise(e.getError()); }
}
%feature("director") Base;

class Base {
public:
  Base();
  Base(int);
  virtual ~Base();
  virtual int ret_m();
};

int call_ret_m(Base *b);
