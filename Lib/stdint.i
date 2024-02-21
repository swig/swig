/* -----------------------------------------------------------------------------
 * stdint.i
 *
 * SWIG library file for ISO C99 types: 7.18 Integer types <stdint.h>
 * ----------------------------------------------------------------------------- */

%{
#if defined __cplusplus && (__cplusplus-0) >= 201103L
# include <cstdint>
#endif
#include <stdint.h>		// Use the C99 official header
%}

%include <swigarch.i>

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

#ifdef __cplusplus
/* Also provide the above in the std namespace. */
namespace std {
using int8_t = ::int8_t;
using int16_t = ::int16_t;
using int32_t = ::int32_t;
using int64_t = ::int64_t;

using uint8_t = ::uint8_t;
using uint16_t = ::uint16_t;
using uint32_t = ::uint32_t;
using uint64_t = ::uint64_t;

using int_least8_t = ::int_least8_t;
using int_least16_t = ::int_least16_t;
using int_least32_t = ::int_least32_t;
using int_least64_t = ::int_least64_t;

using uint_least8_t = ::uint_least8_t;
using uint_least16_t = ::uint_least16_t;
using uint_least32_t = ::uint_least32_t;
using uint_least64_t = ::uint_least64_t;

using int_fast8_t = ::int_fast8_t;
using int_fast16_t = ::int_fast16_t;
using int_fast32_t = ::int_fast32_t;
using int_fast64_t = ::int_fast64_t;

using uint_fast8_t = ::uint_fast8_t;
using uint_fast16_t = ::uint_fast16_t;
using uint_fast32_t = ::uint_fast32_t;
using uint_fast64_t = ::uint_fast64_t;

using intptr_t = ::intptr_t;
using uintptr_t = ::uintptr_t;

using intmax_t = ::intmax_t;
using uintmax_t = ::uintmax_t;
}
#endif
