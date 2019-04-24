%module xxx
/* Note: needs -Wextra to see these warnings */

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
