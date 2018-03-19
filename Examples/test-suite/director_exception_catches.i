%module(directors="1") director_exception_catches

%include <std_string.i>
%feature("director") BaseClass;

%{
// define dummy director exception classes to prevent spurious errors 
// in target languages that do not support directors.

#ifndef SWIG_DIRECTORS
namespace Swig {
  class DirectorException {};
}
#endif /* !SWIG_DIRECTORS */
%}

%catches(Swig::DirectorException) BaseClass::call_description;

%inline %{
struct BaseClass {
  virtual std::string description() const = 0;
  static std::string call_description(BaseClass& bc) { return bc.description(); }
  virtual ~BaseClass() {}
};
%}
