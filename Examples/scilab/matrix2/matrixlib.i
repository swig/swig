%module matrixlib
%typemap (in,noblock=1) (double *first, int nbRow, int nbCol){
  int *piAddr = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, 1, &piAddr);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return 0;
  }
  sciErr = getMatrixOfDouble(pvApiCtx, piAddr, &$2, &$3, &$1);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return 0;
  }
}
%typemap (in) (int *numberOfRow, int *numberOfCol) {
  $1 = &iRowsOut;
  $2 = &iColsOut;
}

%inline {
extern double sumitems(double *first, int nbRow, int nbCol);
extern double* getValues(int *numberOfRow, int *numberOfCol);
}

