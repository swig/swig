%module cpp17_auto_variable_braced

// An 'auto' variable initialised with a braced initialiser holding a single element deduces the type of
// that element.  The declaration is C++11 grammar but the deduction is the C++17 one - in C++11 and C++14
// as published the same declaration deduced std::initializer_list.

// A setter for a pointer variable is not what is under test here.
%immutable ptr_var;
%immutable paren_ptr_var;
%immutable spaced_ptr_var;

// Copy-list-initialisation keeps the C++11 rule and deduces std::initializer_list, whatever the
// number of elements.  SWIG declares std::initializer_list only as a stub that warns rather than
// wrapping, so those declarations are parsed and the variables ignored with warning 346.
#pragma SWIG nowarn=SWIGWARN_CPP11_AUTO

%{
#include <initializer_list>
%}

%inline %{
int global_int = 11;

// Helper proving the deduced type in the target language.
int deref(int *p) { return *p; }

auto int_var{42};

auto double_var{1.5};

auto bool_var{true};

auto negative_var{-5};

auto char_var{'a'};

// A unary '+' or '-' applies the integral promotion, so these deduce int rather than char or bool.
auto promoted_char_var{+'a'};
auto negated_char_var{-'a'};
auto promoted_bool_var{+true};

// The cv-qualifier on the placeholder is kept on the deduced type.
const auto const_var{7};

// Deduction from a variable in scope, and from its address.
auto copy_var{global_int};
auto* ptr_var{&global_int};

// The operand of '&' can be parenthesised or spaced out.
auto* paren_ptr_var{&(global_int)};
auto* spaced_ptr_var{& global_int};

static constexpr auto string_var{"braced"};

// Ignored, and parsing carries on.  Every declarator of one declaration shares the one placeholder,
// so a declaration declaring more than one variable is ignored as a whole.
auto list_var = {1, 2};
auto single_list_var = {3};
auto multi_list_a = {4}, multi_list_b = {5};

int parsing_continues() { return 42; }
%}

%{
// Wunused-variable warning suppression for the variables SWIG drops.
bool warning_suppression() {
  return list_var.size() + single_list_var.size() + multi_list_a.size() + multi_list_b.size() > 0;
}
%}
