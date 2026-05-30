%module cpp17_class_template_argument_deduction

// C++17 added class template argument deduction (CTAD): a variable can be declared with a bare
// class template name, the template arguments deduced from the initializer.  The deduction uses
// guides synthesised from the class's constructors, so the classes below declare constructors to
// make the deduction valid in C++17.  (C++20 P1816 additionally allows CTAD for aggregates with no
// constructor - see the C++20 manual chapter.)
//
// SWIG performs no template argument deduction, so it cannot determine the deduced type of such a
// variable.  It issues Warning 347 and skips the variable rather than generating uncompilable code
// that names the template without arguments.  Other declarations are unaffected.

%include <std_string.i>

%warnfilter(SWIGWARN_CPP17_CLASS_TEMPLATE_ARGUMENT_DEDUCTION);
%warnfilter(SWIGWARN_LANG_IDENTIFIER) IntCase::operator();
%warnfilter(SWIGWARN_LANG_IDENTIFIER) DoubleCase::operator();

%inline %{
#include <string>

struct IntCase    { std::string operator()(int v)    const { return "Int:" + std::to_string(v); } };
struct DoubleCase { std::string operator()(double v) const { return "Double:" + std::to_string(v); } };

template <typename... Ts>
struct Overloaded : Ts... {
    using Ts::operator()...;
    Overloaded(Ts... ts) : Ts(ts)... {}
};

template <typename T>
struct Box {
    T value;
    Box(T v) : value(v) {}
};

// CTAD deduced from each constructor - SWIG warns (347) and skips both variables.
Overloaded ov{ IntCase{}, DoubleCase{} };
Box bx{42};

// An ordinary function declared alongside the skipped CTAD variables still wraps.
inline int unaffected(int x) { return x + 1; }

// C++17 also allows user-defined deduction guides.  A deduction guide is not a function,
// has no body and emits no symbol - it only steers argument deduction at compile time - so SWIG
// parses and discards it.  The non-template form, the templated form written under a template
// parameter list and the 'explicit' specifier are all accepted.
template <typename T>
struct Bag {
    T value;
    Bag(T v) : value(v) {}
};

Bag(int) -> Bag<int>;                                // non-template deduction guide
template <typename T> Bag(T *) -> Bag<T>;            // templated guide under a template parameter list
template <typename T> explicit Bag(T, T) -> Bag<T>;  // explicit deduction guide

// A declaration following the deduction guides still wraps, proving parsing recovers.
inline int after_guides(int x) { return x + 2; }
%}
