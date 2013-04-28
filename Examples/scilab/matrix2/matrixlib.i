%module matrixlib
%include matrix.i


%apply (double* matrixAsInput,int rows,int cols){(double *first, int nbRow, int nbCol)}
%apply (double** matrixAsArgOutput,int* rows,int* cols){(double **result,int* nbRowOut,int* nbColOut)}

%typemap(out) (double*)(int *nRow, int *nCol) 
{
  SciErr sciErr;
  sciErr = createMatrixOfDouble(pvApiCtx, Rhs+$result, *nRow, *nCol, (double *)$1);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return 0;
  }
   AssignOutputVariable(pvApiCtx, outputPosition) = Rhs+$result;
   free($1);
}
%typemap (in,numinputs=0) (int *numberOfRow, int *numberOfCol) 
{
}
%typemap(arginit) (int *numberOfRow, int *numberOfCol) 
{
  $1 =(int*)malloc(sizeof(int));
  $2 =(int*)malloc(sizeof(int)); 
  nRow =$1;
  nCol =$2;
}

%typemap(freearg) (int *numberOfRow, int *numberOfCol) 
{
  free($1);
  free($2);
}



%inline {
 extern void sumitems_argoutput(double *first, int nbRow, int nbCol,double **result,int* nbRowOut,int* nbColOut);
 extern double* getValues(int *numberOfRow, int *numberOfCol);
}

