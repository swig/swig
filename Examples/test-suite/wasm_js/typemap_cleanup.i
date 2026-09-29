%module typemap_cleanup
%ignore resource_live;
%ignore resource_releases;
%inline %{
#include <stdexcept>
typedef int Resource;
int& resource_live() { static int value = 0; return value; }
int& resource_releases() { static int value = 0; return value; }
int live_resources() { return resource_live(); }
int released_resources() { return resource_releases(); }
%}
%typemap(in) Resource (int *temporary = 0, int initialized = 17) {
  if (initialized != 17) SWIG_exception_fail(SWIG_RuntimeError, "Uninitialized typemap local");
  temporary = new int($input);
  ++resource_live();
  $1 = *temporary;
  if ($1 < 0) SWIG_exception_fail(SWIG_TypeError, "Expected nonnegative input");
}
%typemap(freearg) Resource {
  if (temporary$argnum) {
    delete temporary$argnum;
    temporary$argnum = 0;
    --resource_live();
    ++resource_releases();
  }
}
%inline %{
int consume(Resource first, Resource second, bool fail = false) {
  if (fail) throw std::runtime_error("expected call failure");
  return first + second;
}
%}
%typemap(out) int fail_output {
  SWIG_exception_fail(SWIG_TypeError, "Expected output conversion failure");
}
%inline %{
int fail_output(Resource first, Resource second) { return first + second; }
%}
