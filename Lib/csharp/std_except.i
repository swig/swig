%include <std/std_except.i>

// Typemaps used by the STL wrappers that throw exceptions.
// These typemaps are used when methods are declared with an STL exception specification, such as
//   size_t at() const throw (std::out_of_range);

namespace std 
{
  %ignore exception;
  struct exception {};
}

%typemap(throws, canthrow=1) std::out_of_range %{
  SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentOutOfRangeException, 0, $1.what());
  return $null; %}

%typemap(throws, canthrow=1) std::invalid_argument %{
  SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentException, $1.what(), "");
  return $null; %}

