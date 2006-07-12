%module(directors="1") director_classic

%include "std_string.i"

%feature("director");

%inline %{

#include <cstdio>
#include <iostream>
#include <string>

struct Person {
  virtual std::string id() { return "Person"; }
  virtual ~Person() {}
};

struct Child : Person {
  virtual std::string id() { return "Child"; }
};

struct GrandChild : Child {
  virtual std::string id() { return "GrandChild"; }
};

class Caller {
private:
  Person *_callback;
public:
  Caller(): _callback(0) {}
  ~Caller() { delCallback(); }
  void delCallback() { delete _callback; _callback = 0; }
  void setCallback(Person *cb) { delCallback(); _callback = cb; }
  void resetCallback() { _callback = 0; }
  std::string call() { if (_callback) return _callback->id(); else return "oops";  }
  Person* baseClass() { return _callback; }
};

%}

