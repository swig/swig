%module(directors="1") director_exception_nothrow

%include "std_string.i"

%feature("director") Bar;

%{
#if defined(__cplusplus) && __cplusplus >=201103L
#define throw() noexcept
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
