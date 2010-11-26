%insert(runtime) "swigrun.swg";
%insert(runtime) "swigerrors.swg";
%insert(runtime) %{
#ifdef __cplusplus
extern "C" {
#endif

#include "MALLOC.h"

/* Typedefs for integers mapping */
typedef short SCI_INT16_FROM_SHORT;
typedef signed short SCI_INT16_FROM_SIGNED_SHORT;
typedef int SCI_INT32_FROM_INT;
typedef long SCI_INT32_FROM_LONG;
typedef signed int SCI_INT32_FROM_SIGNED_INT;
typedef signed long SCI_INT32_FROM_SIGNED_LONG;

void SWIG_Error(int code, const char *msg)
{
    Scierror(code, _("%s\n"), msg);
}
#ifdef __cplusplus
}
#endif

#define SWIG_contract_assert(expr, msg) if (!(expr)) { SWIG_Error(999, msg); } else 

%}
