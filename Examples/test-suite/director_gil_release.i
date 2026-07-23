#if defined(SWIGPYTHON)
%module(directors="1", threads="1") director_gil_release
#else
%module(directors="1") director_gil_release
#endif

%{
#ifdef _WIN32
#include <windows.h>
#else
#include <unistd.h>
#endif
%}

%director Foo;

%inline %{

class Foo {
public:
  virtual ~Foo() {}
  virtual void blocking_call(int ms) {
#ifdef _WIN32
    Sleep(ms);
#else
    usleep(ms * 1000);
#endif
  }
  int ping() {
    return 42;
  }
};
%}
