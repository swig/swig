%typemap(in) (double* matrixAsInput, int rows, int cols) {
  int *piAddr = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, ++scilabArgNumber, &piAddr);
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

%typemap(in,numinputs=0) (double** matrixAsArgOutput,int* rows, int* cols)
{

}

%typemap(arginit) (double** matrixAsArgOutput,int* rows, int* cols)
{
	$1=(double**)malloc(16*sizeof(double*));
	$2=(int*)malloc(sizeof(int));
	$3=(int*)malloc(sizeof(int));
}

%typemap(argout) (double** matrixAsArgOutput,int* rows, int* cols)
{
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, *$2, *$3, (double *)*$1);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
	 }
	 
	 LhsVar(iOutNum) = iVarOut;
	 iOutNum++;
	 iVarOut++;
}
