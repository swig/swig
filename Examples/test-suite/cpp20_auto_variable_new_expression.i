%module cpp20_auto_variable_new_expression

// C++20 forms of an 'auto' variable initialised by a new-expression.

%immutable;

// A constrained placeholder in the new-expression itself is not parsed, so no type is deduced.
%warnfilter(SWIGWARN_CPP11_AUTO) constrained_allocation;

%inline %{
template<typename T> concept Dereferenceable = requires(T p) { *p; };
template<typename T> concept Addable = requires(T a) { a + a; };

int int_value(int *p) { return *p; }
int int_at(int *values, int i) { return values[i]; }

// The array bound can be deduced from the initialiser.
auto deduced_bound = new int[]{30, 31, 32};

// A constrained placeholder deduces the pointer as a plain one does, or with a '*' declarator what it points to.
Dereferenceable auto constrained_pointer = new int(33);
const Addable auto *constrained_decorated = new int(34);

auto constrained_allocation = new Addable auto(35);
%}
