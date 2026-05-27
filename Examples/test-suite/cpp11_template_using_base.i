%module cpp11_template_using_base

// Exercises a using-declaration that names a member through a type-template
// parameter used directly as the base class.

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE) Overloaded<IntCase, DoubleCase>;

%include <std_string.i>

%inline %{
#include <string>

struct IntCase {
    int seed;
    IntCase() : seed(0) {}
    IntCase(int s) : seed(s) {}
    std::string call(int v) const { return "Int:" + std::to_string(seed + v); }
};
struct DoubleCase {
    std::string call(double v) const { return "Double:" + std::to_string(v); }
};

// Inheriting constructors (using I::I;) and an inherited member (using I::call;)
// through a type-template parameter base.  See issue #2951.
template <typename I>
struct Derived : I {
    using I::I;
    using I::call;
};
%}

%template(DerivedInt) Derived<IntCase>;

%inline %{
template <typename I, typename D>
struct Overloaded : I, D {
    using I::call;
    using D::call;
};
%}

%template(OverloadedIntDouble) Overloaded<IntCase, DoubleCase>;
