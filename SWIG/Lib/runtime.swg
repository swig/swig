/* -----------------------------------------------------------------------------*
   Standard SWIG API for use inside user code.
 
   You need to include in your code as follow:

#include <Python.h>            // or using your favorite language 
#include <swigrun.swg>
#include <python/pyrun.swg>    // or using your favorite language 
#include <runtime.swg>
 
 * -----------------------------------------------------------------------------*/

SWIGRUNTIMEINLINE swig_type_info *
SWIG_Runtime_TypeQuery(const char *name) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  return SWIG_TypeQueryTL(tl, name);
}

SWIGRUNTIMEINLINE swig_type_info *
SWIG_Runtime_TypeRegister(swig_type_info *ti) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  return SWIG_TypeRegisterTL(&tl, ti);
}

SWIGRUNTIMEINLINE void
SWIG_Runtime_TypeClientData(swig_type_info *ti, void *clientdata) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  SWIG_TypeClientDataTL(tl, ti, clientdata);
}

SWIGRUNTIMEINLINE void
SWIG_Runtime_PropagateClientData(swig_type_info *type) {
  swig_type_info *tl = SWIG_Runtime_GetTypeList();
  SWIG_PropagateClientDataTL(tl, type);
}

#define SWIG_GetTypeList()            SWIG_Runtime_GetTypeList()
#define SWIG_TypeQuery(name)          SWIG_Runtime_TypeQuery(name)
#define SWIG_TypeRegister(ti)         SWIG_Runtime_TypeRegister(ti)
#define SWIG_TypeClientData(ti, cd)   SWIG_Runtime_TypeClientData(ti, cd)
#define SWIG_PropagateClientData(ti)  SWIG_Runtime_PropagateClientData(ti)
