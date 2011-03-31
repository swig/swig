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
#define SWIG_fail                                    return 0

#define SWIG_ConvertPtr(obj, vptr, descriptor, flags)     SWIG_Scilab_ConvertPtr(pvApiCtx, obj, vptr, descriptor, flags)
#define SWIG_NewPointerObj(ptr, type, flags)              SWIG_Scilab_NewPointerObj(pvApiCtx, iVarOut, ptr, type, flags)

/* Convert a pointer value */
SWIGRUNTIMEINLINE int
SWIG_Scilab_ConvertPtr(StrCtx* pvApiCtx, int obj, void **ptr, swig_type_info* descriptor, int flags) {
    SciErr sciErr;
    int* piAddrVar = NULL;
    int iType = 0;
    void *_piData = NULL;

    sciErr = getVarAddressFromPosition(pvApiCtx, obj, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_ERROR;
    }

    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_ERROR;
    }
    if (iType != sci_pointer)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), "SWIG_Scilab_ConvertPtr", obj);
        return SWIG_ERROR;
    }

    sciErr = getPointer(pvApiCtx, piAddrVar, ptr);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_ERROR;
    }
    return SWIG_OK;
}

/* Create a new pointer object */
SWIGRUNTIMEINLINE int
SWIG_Scilab_NewPointerObj(StrCtx* pvApiCtx, int iVarOut, void *ptr, swig_type_info *type, int flags) {
    SciErr sciErr;
    sciErr = createPointer(pvApiCtx, iVarOut, (void *)ptr);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  return iVarOut;
}

%}
