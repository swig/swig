%module xxx

// Diagnostics for a C++11 'auto' declaration declaring more than one variable.  Each declarator deduces its own
// type and a declarator SWIG cannot deduce from takes the type its siblings deduced, so a warning is only issued
// when no declarator deduces a type, or when two of them deduce different types.

int g = 7;
int fn(int x);

typedef int myint;
myint m = 4;

// No warning: the second declarator has nothing to deduce from and takes the 'int' of the first, and the other
// way around for the second declaration.
auto first_deduced = 1, later_undeduced = fn(1);
auto first_undeduced = fn(1), later_deduced = 2;

// Neither declarator deduces a type, so both are dropped naming their own initialiser.
auto none_deduced1 = fn(1), none_deduced2 = fn(2);

// The declarators deduce different types, which is not valid C++.  Both are still wrapped, each with the type
// its own initialiser deduces.
auto mismatch_int = 1, mismatch_double = 2.5;
auto mismatch_ptr = &g, mismatch_plain = 1;

// No warning: 'myint' and 'int' are the same type, and SWIG only reports a mismatch between fundamental types
// because a typedef is not resolvable while the declaration is being parsed.
auto typedef_first = m, typedef_second = 1;
