// Test that catching DirectorException in C++ and calling clearPythonError()
// does not leave a stale Python error indicator (issue #2671).

%module(directors="1") director_stale_error

%feature("director") Handler;

%warnfilter(SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) return_const_char_star;

%{
#include <string>
#ifndef SWIG_DIRECTORS
namespace Swig {
  class DirectorException {};
  class DirectorMethodException: public Swig::DirectorException {};
}
#endif
%}

%feature("director:except") %{
  if ($error != NULL) {
    throw Swig::DirectorMethodException();
  }
%}

%inline %{

class Handler {
public:
    Handler() {}
    virtual ~Handler() {}
    virtual int handle(int value) {
        return value * 2;
    }
};

class Invoker {
public:
    Invoker(Handler *h) : handler(h) {}

    int call(int value) {
        try {
            return handler->handle(value);
        } catch (Swig::DirectorException &e) {
            e.clearPythonError();
            return -1;
        }
    }

private:
    Handler *handler;
};

%}
