%module cpp17_auto_variable_braced

// An 'auto' variable initialised with a braced initialiser holding a single element deduces the type of
// that element.  The declaration is C++11 grammar but the deduction is the C++17 one - in C++11 and C++14
// as published the same declaration deduced std::initializer_list.

// A setter for a pointer variable is not what is under test here.
%immutable ptr_var;

%inline %{
int global_int = 11;

// Helper proving the deduced type in the target language.
int deref(int *p) { return *p; }

auto int_var{42};

auto double_var{1.5};

auto bool_var{true};

auto negative_var{-5};

// The cv-qualifier on the placeholder is kept on the deduced type.
const auto const_var{7};

// Deduction from a variable in scope, and from its address.
auto copy_var{global_int};
auto* ptr_var{&global_int};

static constexpr auto string_var{"braced"};
%}
