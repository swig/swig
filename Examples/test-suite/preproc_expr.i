%module preproc_expr

// Check expressions which suffered from incorrect operator precedence prior
// to SWIG 4.1.0.

%inline %{
// `!` should have higher precedence than binary `+`.
#if !0 + 1
#else
# error Bad preprocessor expression operator precedence
#endif

// `!=` should have higher precedence than bitwise and.
#if 1 & 2 != 0
#else
# error Bad preprocessor expression operator precedence
#endif

// `==` should have higher precedence than bitwise or.
#if (2 | 1 == 3) != 2
# error Bad preprocessor expression operator precedence
#endif

// `!=` should have higher precedence than bitwise xor.
#if 1 ^ 2 != 4
# error Bad preprocessor expression operator precedence
#endif

// `<` should have higher precedence than '=='.
#if 2 == 2 < 2
# error Bad preprocessor expression operator precedence
#endif

%}
