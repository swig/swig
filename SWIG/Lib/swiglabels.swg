/***********************************************************************
 *
 *  This section contains generic SWIG labels for method/variable
 *  declarations/attributes, and other compiler dependent labels.
 *
 ************************************************************************/

/* 
   SWIGTEMPLATEDISAMBIGUATOR is needed when wrapping template calls
   (cwrap.c:Swig_cfunction_call/Swig_cmethod_call), as in

     result = nspace::template function<int >(arg1);
     result = arg1->template method<int >(arg2);

    SWIGTEMPLATEDISAMBIGUATOR is compiler dependent (common.swg),
      - SUN Studio requires 'template', 
      - gcc-3.4 forbids the use of 'template'.
      - gcc-3.2.3 produces internal errors if you use 'template'
*/
#ifndef SWIGTEMPLATEDISAMBIGUATOR
#  if defined(__SUNPRO_CC) 
#    define SWIGTEMPLATEDISAMBIGUATOR template
#  else
#    define SWIGTEMPLATEDISAMBIGUATOR 
#  endif
#endif

/* inline attribute */
#ifndef SWIGINLINE
# if defined(__cplusplus) || (defined(__GNUC__) && !defined(__STRICT_ANSI__))
#   define SWIGINLINE inline
# else
#   define SWIGINLINE
# endif
#endif

/* attritbute passed for some compilers to avoid 'unused' warnings */
#ifndef SWIGUNUSED
# if defined(__GNUC__) || defined(__ICC)
#   define SWIGUNUSED __attribute__ ((unused)) 
# else
#   define SWIGUNUSED 
# endif
#endif

/* internal SWIG method */
#ifndef SWIGINTERN
# define SWIGINTERN static SWIGUNUSED
#endif

/* internal inline SWIG method */
#ifndef SWIGINTERNINLINE
# define SWIGINTERNINLINE SWIGINTERN SWIGINLINE
#endif

/* how we export a method such that it can go in to a shared or dll library */
#ifndef SWIGEXPORT
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   if defined(_MSC_VER) || defined(__GNUC__)
#     if defined(STATIC_LINKED)
#       define SWIGEXPORT(a) a
#     else
#       define SWIGEXPORT(a) __declspec(dllexport) a
#     endif
#   else
#     if defined(__BORLANDC__)
#       define SWIGEXPORT(a) a _export
#     else
#       define SWIGEXPORT(a) a
#     endif
#   endif
# else
#   define SWIGEXPORT(a) a
# endif
#endif
