%module cpp11_template_using_base

// Exercises a using-declaration that names a member through a type-template
// parameter used directly as the base class.

// SWIGWARN_LANG_OVERLOAD_SHADOW: lua only has one numeric type, so the int/double overloads of
// call shadow each other.  The other warnings suppress per target multiple inheritance notes.
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
            SWIGWARN_LANG_OVERLOAD_SHADOW) Overloaded<IntCase, DoubleCase>;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
            SWIGWARN_LANG_OVERLOAD_SHADOW) TypedefChainMultiBase;
%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
            SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
            SWIGWARN_D_MULTIPLE_INHERITANCE,
            SWIGWARN_PHP_MULTIPLE_INHERITANCE,
            SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
            SWIGWARN_LANG_OVERLOAD_SHADOW) TypedefArgMultiBase;

#ifdef SWIGD
// D supports single inheritance only.  Without this ignore the using-declaration brings call(double)
// into the D proxy with an 'override' keyword that has no matching base method, a D compile error.
%ignore DoubleCase::call;
#endif

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
    double value;
    DoubleCase(double v = 0.0) : value(v) {}
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
// Inheriting constructors through a typedef-name for a base class that is itself a template instantiation.
// The qualifier is a typedef rather than the base class name, and the base's own constructors were inherited.
// See issue #2951.
struct TypedefMixin : Derived<IntCase> {
    typedef Derived<IntCase> base_type;
    using base_type::base_type;
};
%}

%inline %{
// As above, but the using-declaration qualifier is a typedef of a typedef naming the base class, so resolving it
// to the base class requires following a chain of typedefs.
struct TypedefChainMixin : Derived<IntCase> {
    typedef Derived<IntCase> base_alias;
    typedef base_alias base_type;
    using base_type::base_type;
};
%}

%inline %{
// Multiple bases AND a typedef of a typedef naming the base class: resolving the using-declaration
// qualifier to the correct base needs the full typedef chain even when there is more than one base, so
// the single-base shortcut cannot mask it.  See issue #2951.
struct TypedefChainMultiBase : DoubleCase, Derived<IntCase> {
    typedef Derived<IntCase> base_alias;
    typedef base_alias base_type;
    using base_type::base_type;        // inherits Derived<IntCase>'s (inherited IntCase(int)) constructors
    using Derived<IntCase>::call;      // call(int) so the inherited constructor's seed is observable
    using DoubleCase::call;            // call(double) so the second base is observably present
};
%}

%inline %{
// Multiple bases where the base is named through a typedef whose template argument is itself a typedef.  The
// written form Derived<(IntCaseAlias)> differs from the resolved base name Derived<(IntCase)>, so the immediate
// base is found by resolving the qualifier to a node and matching by identity, not by its written form.  See
// issue #2951.
typedef IntCase IntCaseAlias;
struct TypedefArgMultiBase : DoubleCase, Derived<IntCaseAlias> {
    typedef Derived<IntCaseAlias> base_type;
    using base_type::base_type;        // inheriting constructor through the typedef-argument base
    using Derived<IntCase>::call;      // call(int) so the inherited constructor's seed is observable
    using DoubleCase::call;            // call(double) so the second base is observably present
};
%}

%inline %{
// The base is named through a scope-qualified qualifier (ns2951::QualBase), so the inheriting-constructor
// unqualified-id 'QualBase' must be matched against the last component of the qualifier, not the whole scope
// qualified name.  See issue #2951.
namespace ns2951 {
struct QualBase {
    int seed;
    QualBase() : seed(0) {}
    QualBase(int s) : seed(s) {}
    std::string call(int v) const { return "Int:" + std::to_string(seed + v); }
};
}
struct QualifiedBaseUsing : ns2951::QualBase {
    using ns2951::QualBase::QualBase;
};
struct SemiQualifiedBaseUsing : ns2951::QualBase {
    using QualBase::QualBase; // not fully qualified
};
%}

%inline %{
// The base is reached through a typedef of a typedef whose intermediate typedef lives in a namespace, so the
// inheriting constructor is found by resolving the qualifier through the namespace-scoped chain.  See issue #2951.
namespace ns2951b {
struct NsBase {
    int seed;
    NsBase() : seed(0) {}
    NsBase(int s) : seed(s) {}
    std::string call(int v) const { return "Int:" + std::to_string(seed + v); }
};
}
struct NsChainUsing : ns2951b::NsBase {
    typedef ns2951b::NsBase ns_alias;
    typedef ns_alias ns_base;
    using ns_base::ns_base;
};
%}

%inline %{
template <typename I, typename D>
struct Overloaded : I, D {
    using I::I;
    using D::D;
    using I::call;
    using D::call;
};
%}

%template(OverloadedIntDouble) Overloaded<IntCase, DoubleCase>;
