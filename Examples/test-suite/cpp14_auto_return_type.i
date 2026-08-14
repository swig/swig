// This testcase checks SWIG's support for 'auto' as the return type of a
// function with no trailing return type, introduced in C++14.
%module cpp14_auto_return_type

%warnfilter(SWIGWARN_CPP14_AUTO) forward_decl;
%warnfilter(SWIGWARN_CPP14_AUTO) forward_decl_cref;
%warnfilter(SWIGWARN_CPP14_AUTO) global_cref;
%warnfilter(SWIGWARN_CPP14_AUTO) global_cref2;
%warnfilter(SWIGWARN_CPP14_AUTO) operator==(const teca_variant_array_util::X*, const teca_variant_array_util::X&);

// SWIG can't deduce the return type, so we ignore the 'auto'-using declaration
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

// Same workaround for a cv-qualified auto return type
%extend X {
  int cref() const { return $self->cref(); }
}
%ignore X::cref() const;

// SWIGWARN_CPP14_AUTO warning can be suppressed using either %ignore or %warnfilter...
%ignore X::s();
%warnfilter(SWIGWARN_CPP14_AUTO) X::e() const;
%warnfilter(SWIGWARN_CPP14_AUTO) X::cref2() const;
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
  // Forward declaration (parse error with SWIG < 4.4).
  auto forward_decl() const;
  // Cv-qualified auto return type, either ordering.
  const auto& cref() const {
    static const int i = 42;
    return i;
  }
  auto const& cref2() const {
    static const int i = 43;
    return i;
  }
  const auto& forward_decl_cref() const;
};
}
// More forward declarations (parse error with SWIG < 4.4).
auto operator==(const teca_variant_array_util::X*,const teca_variant_array_util::X&);
auto forward_decl();
// Cv-qualified forward declarations.
const auto& global_cref();
auto const& global_cref2();

%}

// A conversion function can have a deduced return type too.
// SWIG cannot deduce it, so the same workaround applies - here %extend provides a member
// function calling the conversion function.
%warnfilter(SWIGWARN_CPP14_AUTO) Deduced::operator auto;

%extend Deduced {
  int toInt() const { return static_cast<int>(*$self); }
}

%inline %{
struct Deduced {
  int v;
  Deduced(int vv) : v(vv) {}
  operator auto() const { return v; }
};
%}
