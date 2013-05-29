%typemap(in) (double* matrixAsInput, int rows, int cols) {
  int *piAddr = NULL;
  SciErr sciErr;
  sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddr);
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

%typemap(freearg) (double** matrixAsArgOutput,int* rows, int* cols)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout) (double** matrixAsArgOutput,int* rows, int* cols)
{
  SciErr sciErr;
  sciErr = createMatrixOfDouble(pvApiCtx,  Rhs +$result, *$2, *$3, (double *)*$1);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return 0;
  }
  AssignOutputVariable(pvApiCtx, outputPosition) = Rhs +$result;

}


