// Test "Missing identifier for ..." errors
%module xxx

#ifdef
#endif

#ifndef
#endif

#if
#endif

#if defined(AAA)
#elif
#endif


#define BBB

#if !defined(BBB)
#elif
#endif
