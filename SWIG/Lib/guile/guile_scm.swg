/* -*- c -*-
   This SWIG interface file is processed if the Guile module is run
   with SCM_ flavor.
*/

#define SWIGGUILE_SCM

%runtime "precommon.swg"
%runtime "common.swg"

#ifdef SWIG_RUNTIME_MODE
/* Hook the runtime module initialization
   into the shared initialization function SWIG_Guile_Init. */
%runtime %{
/* Hook the runtime module initialization
   into the shared initialization function SWIG_Guile_Init. */
#include <libguile.h>
SCM scm_init_Swig_swigrun_module (void);
#define SWIG_INIT_RUNTIME_MODULE scm_init_Swig_swigrun_module();
%}
#endif

%runtime "guile_scm_run.swg"
%include "ghinterface.i"
%include "guile.i"

%runtime %{

#define GUILE_MAYBE_VALUES \
      if (gswig_list_p) gswig_result = scm_values(gswig_result);

#define GUILE_MAYBE_VECTOR \
      if (gswig_list_p) gswig_result = scm_vector(gswig_result);

#define SWIG_APPEND_VALUE(object)						\
    if (gswig_result == SCM_UNSPECIFIED)						\
        gswig_result = object;							\
    else {									\
      if (!gswig_list_p) {							\
	      gswig_list_p = 1;							\
	      gswig_result = scm_listify(gswig_result, object, SCM_UNDEFINED);	\
      }									\
      else									\
            gswig_result = scm_append(scm_listify(gswig_result, scm_listify(object, SCM_UNDEFINED), SCM_UNDEFINED));		\
    }
    /* used by Lib/exception.i */
    #define gh_symbol2scm scm_str2symbol
    /* useb by Lib/cdata.i */
    #define gh_str2scm scm_mem2string

%}

%init %{
  static int _swig_init = 0;

  if (!_swig_init) {
    int i;
    for (i = 0; swig_types_initial[i]; i++) {
      swig_types[i] = SWIG_TypeRegister(swig_types_initial[i]);
    }
    for (i = 0; swig_types_initial[i]; i++) {
      SWIG_PropagateClientData(swig_types[i]);
    }
    _swig_init = 1;
  }

  SWIG_Guile_Init();
%}
