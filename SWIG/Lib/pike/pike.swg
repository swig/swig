/* -----------------------------------------------------------------------------
 * pike.swg
 *
 * Pike configuration module.
 * ----------------------------------------------------------------------------- */

%insert(runtime) "common.swg";          // Common type-checking code
%insert(runtime) "pikerun.swg";         // Pike run-time code

%insert(runtime) %{
#ifdef __cplusplus
extern "C" {
#endif
#include "global.h"
#include "interpret.h"

/* This must be included last! */
#include "module_magic.h"
#ifdef __cplusplus
}
#endif
%}

/************************* Input Typemaps *****************************/

%typemap(in, pikedesc="tInt")
    int, unsigned int, short, unsigned short,
    long, unsigned long, signed char, unsigned char,
    bool, enum SWIGTYPE
{
    if ($input.type != T_INT)
        Pike_error("Bad argument: Expected an integer.\n");
    $1 = ($1_ltype) $input.u.integer;
}
	
%typemap(in, pikedesc="tFloat") float, double {
    if ($input.type != T_FLOAT)
        Pike_error("Bad argument: Expected a float.\n");
    $1 = ($1_ltype) $input.u.float_number;
}

%typemap(in, pikedesc="tStr") char *, char [ANY] {
    if ($input.type != T_STRING)
        Pike_error("Bad argument: Expected a string.\n");
    $1 = ($1_ltype) STR0($input.u.string);
}

/* Typemaps for pointers.  Note: the SWIG run-time type checker works
   even if a pointer happens to be mapped to a Pike class */

%typemap(in) SWIGTYPE *,
             SWIGTYPE &,
             SWIGTYPE []
	"SWIG_ConvertPtr($input.u.object, (void **) &$1, $1_descriptor, 1);"
	
/************************ Output Typemaps *****************************/

%typemap(out, pikedesc="tInt")
    int, unsigned int,
    short, unsigned short,
    long, unsigned long,
    signed char, unsigned char, 
    bool, enum SWIGTYPE
	"push_int($1);";

%typemap(out, pikedesc="tInt64") long long	"push_int64($1);";
%typemap(out, pikedesc="tFloat") float, double	"push_float($1);";
%typemap(out, pikedesc="tStr") char *		"push_text($1);";

/* Void return value; don't push anything */
%typemap(out, pikedesc="tVoid") void		"";

/* Pointers, references, and arrays */
%typemap(out) SWIGTYPE*, SWIGTYPE &, SWIGTYPE []
        "$result = SWIG_NewPointerObj((void *) $1, $1_descriptor, $owner);";

/************************ Constant Typemaps *****************************/

%typemap(constant)
    int, unsigned int,
    short, unsigned short,
    long, unsigned long,
    signed char, unsigned char, 
    bool, enum SWIGTYPE
	"add_integer_constant(\"$symname\", $1, 0);";

%typemap(constant) float, double
	"add_float_constant(\"$symname\", $1, 0);";

%typemap(constant) char *
	"add_string_constant(\"$symname\", $1, 0);";

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in, pikedesc="tStr") (char *STRING, int LENGTH) {
    if ($input.type != T_STRING)
        Pike_error("Bad argument: Expected a string.\n");
    $1 = ($1_ltype) STR0($input.u.string);
    $2 = ($2_ltype) $input.u.string->length;
}

/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%typemap(in, pikedesc="tInt") size_t {
    if ($input.type != T_INT)
        Pike_error("Bad argument: Expected an integer.\n");
    $1 = ($1_ltype) $input.u.integer;
}

%typemap(out)      size_t = long;

/* ------------------------------------------------------------
 * The start of the Pike initialization function
 * ------------------------------------------------------------ */

%init %{
#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) pike_module_exit(void) {}

#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT(void) pike_module_init(void) {
    struct program *pr;
    int i;
    for (i = 0; swig_types_initial[i]; i++) {
        swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }
%}
