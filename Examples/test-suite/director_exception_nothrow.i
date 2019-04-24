%module(directors="1") director_exception_nothrow

%include "std_string.i"

%feature("director") Bar;

%{
#if defined(_MSC_VER)
  #pragma warning(disable: 4290) // C++ exception specification ignored except to indicate a function is not __declspec(nothrow)
#endif
%}

%inline %{
#include <string>

class Base
{
public:
  virtual ~Base() throw() {}
};


class Bar : public Base
{
public:
  virtual std::string pang() throw() { return "Bar::pang()"; }
};
%}
