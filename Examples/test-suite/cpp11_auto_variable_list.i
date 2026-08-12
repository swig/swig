%module cpp11_auto_variable_list

// C++11 'auto' declarations that declare more than one variable.  C++ requires every declarator in the
// list to deduce to the same type, so a declarator SWIG cannot deduce a type from takes the type deduced
// for its siblings, while each declarator keeps its own decoration.

// A setter for a pointer variable is not what is under test here.
%immutable ptr_first;
%immutable ptr_second;

// SWIG cannot deduce a type from a function call, so both declarators are ignored with a warning.
%warnfilter(SWIGWARN_CPP11_AUTO) undeduced_first;
%warnfilter(SWIGWARN_CPP11_AUTO) undeduced_second;

%inline %{
int global_int = 11;

int call_count() { return 1; }

// Helper proving the deduced type in the target language.
int deref(int *p) { return *p; }

auto int_first = 1, int_second = 2;

auto double_first = 1.5, double_second = 2.5;

const auto const_first = 10, const_second = 20;

// The decoration belongs to the declarator, so only the second of these is a pointer.
auto plain_first = 3, *ptr_second = &global_int;

// And the other way around.
auto *ptr_first = &global_int, plain_second = 4;

// SWIG cannot deduce from the first initialiser, so the type comes from the second declarator.
auto late_first = call_count(), late_second = 5;

auto undeduced_first = call_count(), undeduced_second = call_count();
%}

%{
// Wunused-variable warning suppression for the variables SWIG drops.
bool warning_suppression() {
  return undeduced_first != 0 || undeduced_second != 0;
}
%}
