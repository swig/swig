%runtime %{
#define SWIG_malloc(size) \
  SCM_MUST_MALLOC(size)
#define SWIG_free(mem) \
  scm_must_free(mem)
#define SWIG_ConvertPtr(s, result, type, flags) \
  SWIG_Guile_GetPtr(s, result, type)
#define SWIG_MustGetPtr(s, type, argnum, flags) \
  SWIG_Guile_MustGetPtr(s, type, argnum, FUNC_NAME)
#define SWIG_NewPointerObj(ptr, type, owner) \
  SWIG_Guile_MakePtr((void*)ptr, type)
%}

%runtime "guile_gh_run.swg"
%include "guile.i"

%init %{
  static int _swig_init = 0;

  if (!_swig_init) {
    SWIG_Guile_RegisterTypes(swig_types, swig_types_initial);
    _swig_init = 1;
  }
%}
