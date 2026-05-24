%module cpp20_variable_templates

// C++20 added the ability to initialise a variable template from a
// requires-expression.  A %template instantiation of such a variable is
// wrapped as a read only variable holding the bool the expression
// evaluates to.

%inline %{
template<typename T>
constexpr bool Addable = requires (T t) { t + t; };

// Empty struct without an operator+, so Addable<NotAddable> is false.
struct NotAddable {};
%}

%template(addable_int)        Addable<int>;          // true: int + int compiles
%template(addable_notaddable) Addable<NotAddable>;   // false: NotAddable has no operator+
