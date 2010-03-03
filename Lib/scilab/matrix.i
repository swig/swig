%typemap(in) (double*, int, int) {
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
