/*
 *	ISO C99: 7.18 Integer types <stdint.h>
 */

%{
#include <stdint.h>
%}

/* 32bit/64bit code specialization and checking 
 
   Use only in extreme cases, when no arch. independent code can be
   generated
   
   To activate architecture specific code, use

       swig -DSWIGWORDSIZE32

   or

       swig -DSWIGWORDSIZE64


   Note that extra checking code will be added to the wrapped code,
   which will prevent the compilation in a different architecture.

   If you don't specify the SWIGWORDSIZE (the default case), swig will
   generate architecture independent and/or 32bits code, with no extra
   checking code added.

*/
#if !defined(SWIGWORDSIZE32) &&  !defined(SWIGWORDSIZE64)
# if (__WORDSIZE == 32)
#  define SWIGWORDSIZE32
# endif
#endif
  
#if !defined(SWIGWORDSIZE64) &&  !defined(SWIGWORDSIZE32) 
# if defined(__x86_64) || defined(__x86_64__) || (__WORDSIZE == 64)
#  define SWIGWORDSIZE64
# endif
#endif


#ifdef SWIGWORDSIZE32
%{
#define SWIGWORDSIZE32
#if LONG_MAX != INT_MAX
# error "SWIG wrapped code invalid in 64 bit architecture, regenarete code using -DSWIGWORDSIZE64"
#endif
%}
#endif

#ifdef SWIGWORDSIZE64
%{
#define SWIGWORDSIZE64
#if LONG_MAX == INT_MAX
# error "SWIG wrapped code invalid in 32 bit architecture, regenarete code using -DSWIGWORDSIZE32"
#endif
%}
#endif
  

/* Exact integral types.  */

/* Signed.  */

typedef signed char		int8_t;
typedef short int		int16_t;
typedef int			int32_t;
#if defined(SWIGWORDSIZE64)
typedef long int		int64_t;
#else
typedef long long int		int64_t;
#endif

/* Unsigned.  */
typedef unsigned char		uint8_t;
typedef unsigned short int	uint16_t;
typedef unsigned int		uint32_t;
#if defined(SWIGWORDSIZE64)
typedef unsigned long int	uint64_t;
#else
typedef unsigned long long int	uint64_t;
#endif


/* Small types.  */

/* Signed.  */
typedef signed char		int_least8_t;
typedef short int		int_least16_t;
typedef int			int_least32_t;
#if defined(SWIGWORDSIZE64)
typedef long int		int_least64_t;
#else
typedef long long int		int_least64_t;
#endif

/* Unsigned.  */
typedef unsigned char		uint_least8_t;
typedef unsigned short int	uint_least16_t;
typedef unsigned int		uint_least32_t;
#if defined(SWIGWORDSIZE64)
typedef unsigned long int	uint_least64_t;
#else
typedef unsigned long long int	uint_least64_t;
#endif


/* Fast types.  */

/* Signed.  */
typedef signed char		int_fast8_t;
#if defined(SWIGWORDSIZE64)
typedef long int		int_fast16_t;
typedef long int		int_fast32_t;
typedef long int		int_fast64_t;
#else
typedef int			int_fast16_t;
typedef int			int_fast32_t;
typedef long long int		int_fast64_t;
#endif

/* Unsigned.  */
typedef unsigned char		uint_fast8_t;
#if defined(SWIGWORDSIZE64)
typedef unsigned long int	uint_fast16_t;
typedef unsigned long int	uint_fast32_t;
typedef unsigned long int	uint_fast64_t;
#else
typedef unsigned int		uint_fast16_t;
typedef unsigned int		uint_fast32_t;
typedef unsigned long long int	uint_fast64_t;
#endif


/* Types for `void *' pointers.  */
#if defined(SWIGWORDSIZE64)
typedef long int		intptr_t;
typedef unsigned long int	uintptr_t;
#else
typedef int			intptr_t;
typedef unsigned int		uintptr_t;
#endif


/* Largest integral types.  */
#if defined(SWIGWORDSIZE64)
typedef long int		intmax_t;
typedef unsigned long int	uintmax_t;
#else
typedef long long int		intmax_t;
typedef unsigned long long int	uintmax_t;
#endif


