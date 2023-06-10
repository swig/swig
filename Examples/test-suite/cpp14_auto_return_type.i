// This testcase checks SWIG's support for `auto` as the return type of a
// function with no trailing return type, introduced in C++14.
%module cpp14_auto_return_type

// SWIG can't deduce the return type, so we ignore the `auto`-using declaration
// (which would typically be in a header being wrapped) and provide a
// declaration with an explicit return type in the interface file.

namespace teca_variant_array_util {
// Workaround to wrap a global function containing an auto return type with no trailing return type
int va_static_cast();
%ignore va_static_cast();

// Workaround to wrap a class method containing an auto return type with no trailing return type
%extend X {
  const char * a() const { return $self->a(); }
}
%ignore X::a() const;

// SWIGWARN_CPP14_AUTO warning can be suppressed using either %ignore or %warnfilter...
%ignore X::s();
%warnfilter(SWIGWARN_CPP14_AUTO) X::e() const;
}

%inline %{
namespace teca_variant_array_util
{
// Parse error in SWIG < 4.2.0.
auto va_static_cast()
{
  return 42;
}
struct X {
  auto a() const {
    return "a string";
  }
  auto e() const {
    return 2.71828;
  }
  static auto s() {
    return true;
  }
};
}
%}
