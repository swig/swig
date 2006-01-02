%include <std/std_except.i>

// Typemaps used by the STL wrappers that throw exceptions.
// These typemaps are used when methods are declared with an STL exception specification, such as
//   size_t at() const throw (std::out_of_range);


namespace std 
{
  %ignore exception;
  struct exception {};
}


%typemap(throws) std::out_of_range %{
  SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, $1.what());
  return $null; %}
