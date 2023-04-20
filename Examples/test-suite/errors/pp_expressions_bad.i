%module xxx


/* Divide by zero */
#define ZERO 0

#if 1%ZERO
#endif
#if 2/ZERO
#endif

#if 1%(5-5)
#endif
#if 2/(55-55)
#endif

/* Floating point */
#if 1.2
#endif

#if 2e3
#endif

#if 0
#elif 8.8
#endif

/* Missing whitespace after preproc directive */
#if123
#endif

#if456e
#endif

#if 0
#warning This should not warn
#elif1
#warning This should also not warn
#endif

#if(1)
#warning Warning okay: #if(1)
#endif

/* The SWIG preprocessor support strings with equality/inequality tests.
 * Check error cases.
 */
#if "TWO" == 1
#endif

/* This didn't fail prior with SWIG < 4.1.  Github #1384. */
#if 1 == ("TWO")
#endif

/* These should all give errors. */
#if "1"
#endif
#if -"1"
#endif
#if "1" == -"-1"
#endif
#if "1" == !"-1"
#endif
#if "1" == ~"1"
#endif
/* Unary + was a no-op and so this didn't give an error in SWIG < 4.1.0. */
#if "1" == +"1"
#endif

/* Spaceship operator doesn't seem to be allowed in preprocessor expressions,
 * and isn't valid in C at all.
 */
#if (4 <=> 2) < 0
#endif
