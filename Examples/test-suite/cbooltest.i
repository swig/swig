%module cbooltest

%{
#if defined __STDC_VERSION__ && __STDC_VERSION__ >= 199901L
/* C99 _Bool should be supported by the compiler. */
# include <stdbool.h>
#elif defined __cplusplus
/* Some target languages compile this as C++, which has bool, but the stdbool.h of some compilers defines _Bool */
# ifndef _Bool
#  define _Bool bool
# endif
#else
/* C99 _Bool and stdbool.h may not be supported, so define a hacky version so
 * we can still test SWIG's support. */
# ifndef bool
#  define _Bool unsigned char
#  define bool _Bool
# endif
# ifndef true
#  define true 1
#  define false 0
# endif
#endif
%}

%inline %{
_Bool do_and(_Bool a, _Bool b) { return a && b; }
_Bool do_or(_Bool a, _Bool b) { return a || b; }
%}

%constant _Bool TRUE_CONSTANT = true;
%constant _Bool FALSE_CONSTANT = false;
