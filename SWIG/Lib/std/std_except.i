// Typemaps used by the STL wrappers that throw exceptions.
// These typemaps are used when methods are declared with an STL exception specification, such as
//   size_t at() const throw (std::out_of_range);

#if defined(SWIGJAVA)
  %typemap(throws) std::out_of_range %{
    SWIG_JavaThrowException(jenv, SWIG_JavaIndexOutOfBoundsException, $1.what());
    return $null; %}
#elif defined(SWIGCSHARP)
  %typemap(throws, canthrow=1) std::out_of_range %{
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentOutOfRangeException, 0, $1.what());
    return $null; %}
  %typemap(throws, canthrow=1) std::invalid_argument %{
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentException, $1.what(), "");
    return $null; %}
#elif defined(SWIGPYTHON)
  %include "exception.i"
  %typemap(throws) std::out_of_range %{
    if (!PyErr_Occurred()) {
      SWIG_exception(SWIG_IndexError, $1.what());
    } else {
      SWIG_fail;
    } %}
  %typemap(throws) std::invalid_argument %{
    if (!PyErr_Occurred()) {
      SWIG_exception(SWIG_TypeError, $1.what());
    } else {
      SWIG_fail;
    } %}
#elif
  %include "exception.i"
  %typemap(throws) std::out_of_range %{
    SWIG_exception(SWIG_IndexError, $1.what()); %}
#endif

