/* -*- c -*-
   This SWIG interface file is processed if the Guile module is run
   with gh_ flavor.
*/

#define SWIGGUILE_GH

%runtime "swigrun.swg"
%runtime "guile_gh_run.swg"
%include <guile.i>

%runtime %{

/* scm_values was implemented on C level in 1.4.1, and the prototype
   is not included in libguile.h, so play safe and lookup `values'... */
#define GUILE_MAYBE_VALUES						\
    if (gswig_list_p)							\
        gswig_result = gh_apply(gh_lookup("values"), gswig_result);
    
#define GUILE_MAYBE_VECTOR				\
    if (gswig_list_p)					\
        gswig_result = gh_list_to_vector(gswig_result);

#define SWIG_APPEND_VALUE(object)						\
    if (gswig_result == SCM_UNSPECIFIED) {		\
        gswig_result = object;							\
    } else {									\
        if (!gswig_list_p) {							\
	    gswig_list_p = 1;							\
	    gswig_result = gh_list(gswig_result, object, SCM_UNDEFINED);	\
        }									\
        else									\
            gswig_result = gh_append2(gswig_result,				\
                                      gh_list(object, SCM_UNDEFINED));		\
    }

%}

%init "swiginit.swg"

%init %{
static int _swig_module_smob_tag;

SWIG_GUILE_INIT_STATIC void
SWIG_init(void)
{

  SWIG_InitializeModule(0);
  swig_module.clientdata = (void *) &_swig_module_smob_tag;

  SWIG_Guile_Init(&swig_module);
%}
