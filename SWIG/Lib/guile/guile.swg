/* -----------------------------------------------------------------------
 * swig_lib/guile/guile.swg
 *
 * Guile configuration file.
 * ----------------------------------------------------------------------- */

#include "guile/gh.h"

#define GH_NOT_PASSED    SCM_UNDEFINED

#define GUILE_APPEND_RESULT(object)                                      \
    if (gswig_result == GH_UNSPECIFIED)                                  \
        gswig_result = object;                                           \
    else {                                                               \
        if (!gh_pair_p(gswig_result))                                    \
	    gswig_result = gh_list(gswig_result, object, GH_NOT_PASSED); \
        else                                                             \
            gswig_result = gh_append2(gswig_result,                      \
                                      gh_list(object, GH_NOT_PASSED));   \
    }

/* guile.swg ends here */
