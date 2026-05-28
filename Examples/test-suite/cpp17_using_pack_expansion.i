%module cpp17_using_pack_expansion

// C++17 added pack expansion in a using-declaration ('using Ts::name...;') - P0195.  Its typical
// usage is the 'Overloaded' helper combined with std::visit on a std::variant:
//
//   template <typename... Ts> struct Overloaded : Ts... { using Ts::operator()...; };
//
// The using-declaration pulls each base's operator() into Overloaded's overload set, so calling
// an Overloaded instance dispatches by argument type to the matching base.  This testcase
// exercises that grammar with ordinary functor structs as the operator() bases (pure C++17);
// visit_functors_int() and visit_functors_double() show the typical c++ std::visit idiom.

%include <std_string.i>

// SWIGWARN_LANG_OVERLOAD_SHADOW: lua only has one numeric type, so the int/double overloads of
// operator() shadow each other.  The other warnings suppress per target multiple inheritance notes.
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
            SWIGWARN_LANG_OVERLOAD_SHADOW) Mixed<int, double>;

#ifdef SWIGD
// D supports single inheritance only.  Without these ignores the using-declaration brings the
// second base's operator()(double) into the D proxy with an 'override' keyword that has no
// matching base method, a D compile error.
%ignore DoubleCase::operator();
%ignore Base<double>::operator();
#endif

%rename(call) *::operator();

%inline %{
#include <string>
#include <variant>

struct IntCase    { std::string operator()(int v)    const { return "Int:" + std::to_string(v); } };
struct DoubleCase { std::string operator()(double v) const { return "Double:" + std::to_string(v); } };

template <typename... Ts>
struct Overloaded : Ts... {
    using Ts::operator()...;
};

template <typename T>
struct Base {
    std::string operator()(T v) const { return "T:" + std::to_string(v); }
};

// 'Mixed<Ts...>' uses a nested qualifier inside the using-declaration
// ('using Base<Ts>::operator()...;'), so the pack name expands inside the template-id of the base
// rather than as the leading scope.
template <typename... Ts>
struct Mixed : Base<Ts>... {
    using Base<Ts>::operator()...;
};

// Member methods either side of the pack using-declaration.  When the pack is empty the
// using-declaration is removed and the surrounding member methods must remain in the
// instantiated class with their sibling chain intact.
template <typename... Ts>
struct WithMembers : Ts... {
    std::string before_using() const { return "before"; }
    using Ts::operator()...;
    std::string after_using() const { return "after"; }
};

inline std::string visit_functors_int(int x) {
    std::variant<int,double> v{x};
    return std::visit(Overloaded<IntCase,DoubleCase>{}, v);
}
inline std::string visit_functors_double(double x) {
    std::variant<int,double> v{x};
    return std::visit(Overloaded<IntCase,DoubleCase>{}, v);
}
%}

%template(OverloadedIntDouble) Overloaded<IntCase,DoubleCase>;
%template(BaseInt) Base<int>;
%template(BaseDouble) Base<double>;
%template(MixedIntDouble) Mixed<int, double>;

// Empty pack: the using-declaration introduces no names, so the instantiated class has no
// inherited operator() and the proxy class is constructible but exposes no call methods.
// WithMembersEmpty additionally checks that the surrounding member methods survive intact
// when the using-decl is removed from between them.
%template(OverloadedEmpty) Overloaded<>;
%template(MixedEmpty) Mixed<>;
%template(WithMembersEmpty) WithMembers<>;
