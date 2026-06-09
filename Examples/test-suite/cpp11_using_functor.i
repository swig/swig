%module cpp11_using_functor

// C++11 form of the Overloaded functor helper: two concrete type parameters with explicit
// using-declarations to merge their operator() overloads.  This is the pattern that the C++17
// pack expansion in a using-declaration ('using Ts::operator()...;') generalises - see
// cpp17_using_pack_expansion.
//
// %rename(call) maps operator() to a valid identifier so SWIG can wrap it.  %template then
// instantiates Overloaded<IntCase,DoubleCase>: SWIG substitutes I->IntCase, D->DoubleCase, the
// using-declarations resolve to known methods, and the proxy class gets an overloaded call(int) /
// call(double) that dispatches to the correct base.

// SWIGWARN_LANG_OVERLOAD_SHADOW: lua only has one numeric type, so the int/double overloads of
// operator() shadow each other.  The other warnings suppress per target multiple inheritance notes.
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
            SWIGWARN_LANG_OVERLOAD_SHADOW) Overloaded<IntCase, DoubleCase>;

#ifdef SWIGD
// D supports single inheritance only.  Without this ignore the using-declaration brings operator()(double)
// into the D proxy with an 'override' keyword that has no matching base method, a D compile error.
%ignore DoubleCase::operator();
#endif

%include <std_string.i>

%rename(call) *::operator();

%inline %{
#include <string>

struct IntCase    { std::string operator()(int v)    const { return "Int:" + std::to_string(v); } };
struct DoubleCase { std::string operator()(double v) const { return "Double:" + std::to_string(v); } };

template <typename I, typename D>
struct Overloaded : I, D {
    using I::operator();
    using D::operator();
};
%}

%template(OverloadedIntDouble) Overloaded<IntCase,DoubleCase>;
