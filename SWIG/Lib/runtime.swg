/* -----------------------------------------------------------------------------*
   Standard SWIG API for use inside user code.
 
   You need to include in your code as follow:

#include <Python.h>            // or using your favorite language 
#include <swigrun.swg>
#include <python/pyrun.swg>    // or using your favorite language 
#include <runtime.swg>

   For perl, the following
#include <swigrun.swg>
#include <perl5/perlrun.swg>
#include <runtime.swg>
 
 * -----------------------------------------------------------------------------*/

#ifdef SWIG_MODULE_CLIENTDATA_TYPE

SWIGRUNTIMEINLINE swig_type_info *
SWIG_TypeQuery(SWIG_MODULE_CLIENTDATA_TYPE clientdata, const char *name) {
  swig_module_info *module = SWIG_Runtime_GetModule(clientdata);
  return SWIG_TypeQueryModule(module, module, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_MangledTypeQuery(SWIG_MODULE_CLIENTDATA_TYPE clientdata, const char *name) {
  swig_module_info *module = SWIG_Runtime_GetModule(clientdata);
  return SWIG_MangledTypeQueryModule(module, module, name);
}

#else

SWIGRUNTIMEINLINE swig_type_info *
SWIG_TypeQuery(const char *name) {
  swig_module_info *module = SWIG_Runtime_GetModule();
  return SWIG_TypeQueryModule(module, module, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_MangledTypeQuery(const char *name) {
  swig_module_info *module = SWIG_Runtime_GetModule();
  return SWIG_MangledTypeQueryModule(module, module, name);
}

#endif
