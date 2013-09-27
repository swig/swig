%module infinity

#include <math.h>

/*  C99 defines INFINITY
    Because INFINITY may be defined by compiler built-ins, we can't use #define.
    Instead, expose the variable MYINFINITY and then use %rename to make it INFINITY in the scripting language.
*/
%rename(INFINITY) MYINFINITY;


%inline %{
#include <math.h>

/* C99 math.h defines INFINITY. If not available, this is the fallback. */
#ifndef INFINITY
	#ifdef _MSC_VER
		union MSVC_EVIL_FLOAT_HACK
		{
			unsigned __int8 Bytes[4];
			float Value;
		};
		static union MSVC_EVIL_FLOAT_HACK INFINITY_HACK = {{0x00, 0x00, 0x80, 0x7F}};
		#define INFINITY (INFINITY_HACK.Value)
	#endif

	#ifdef __GNUC__
		#define INFINITY (__builtin_inf())
    #elif defined(__clang__)
		#if __has_builtin(__builtin_inf)
			#define INFINITY (__builtin_inf())
		#endif
	#endif

	#ifndef INFINITY
		#define INFINITY (1e1000)
	#endif
#endif

/* This will allow us to bind the real INFINITY value through SWIG via MYINFINITY. Use %rename to fix the name. */
const double MYINFINITY = INFINITY;

/* Use of float is intentional because the original bug was in the float conversion due to overflow checking. */
float use_infinity(float inf_val)
{
    return inf_val;
}
%}
