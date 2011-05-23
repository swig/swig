%{
#include <vector>
%}

namespace std {

  template<class T> class vector {
    %define SCILAB_STD_VECTOR_IN(T, TYPECHECKINGFUNCTION, TEMPTYPE, READFUNCTIONNAME)
      %typemap(in) vector<T> {
      SciErr sciErr;
      int *piAddrVar    = NULL;
      int *piChild      = NULL;
      int iType         = 0;
      int iNumberOfItem = 0;
      TEMPTYPE *tempValue  = NULL;
      int iRows = 0;
      int iCols = 0;

      sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }

      /* Check input type */
      sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
      if (iType != sci_list) {
        Scierror(999, _("%s: Wrong type for input argument #%d: A list expected.\n"), fname, $argnum);
        return 0;
      }

      /* Get list size */
      sciErr = getListItemNumber(pvApiCtx, piAddrVar, &iNumberOfItem);
      if(sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }

      $1 = std::vector<T>(iNumberOfItem);

      for (unsigned int i=0; i<iNumberOfItem; i++) {
        sciErr = getListItemAddress(pvApiCtx, piAddrVar, i + 1, &piChild);
        if(sciErr.iErr) {
          printError(&sciErr, 0);
          return SWIG_ERROR;
        }

        if (!TYPECHECKINGFUNCTION(pvApiCtx, piChild)) {
          Scierror(999, _("%s: Wrong type for item #%d: A real scalar expected.\n"), fname, i + 1);
          return 0;
        }
        sciErr = READFUNCTIONNAME(pvApiCtx, piAddrVar, i + 1, &iRows, &iCols, &tempValue);
        if(sciErr.iErr) {
          printError(&sciErr, 0);
          return SWIG_ERROR;
        }
        if (iRows * iCols != 1) {
          Scierror(999, _("%s: Wrong size for item #%d: A real scalar expected.\n"), fname, i + 1);
          return 0;
        }
        (($1_type &)$1)[i] = (T)*tempValue;
      }
    }
    %enddef
    %typemap(out) vector<T>* {
      /* %typemap(out) vector<T>* */
      SciErr sciErr;
      int *piAddrVar = NULL;
      sciErr = createList(pvApiCtx, Rhs + $result, 0, &piAddrVar);
      if(sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
      SwigScilabSetOutput(1, Rhs + $result);
    }
    SCILAB_STD_VECTOR_IN(double, isDoubleType, double, getMatrixOfDoubleInList);
    SCILAB_STD_VECTOR_IN(int, isDoubleType, double, getMatrixOfDoubleInList);
  };
}

