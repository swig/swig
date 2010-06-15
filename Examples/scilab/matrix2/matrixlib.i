%module matrixlib
%include matrix.i




%apply (double* matrixAsInput,int rows,int cols){(double *first, int nbRow, int nbCol)}
%apply (double** matrixAsArgOutput,int* rows,int* cols){(double **result,int* nbRowOut,int* nbColOut)}
%inline {
extern void sumitems_argoutput(double *first, int nbRow, int nbCol,double **result,int* nbRowOut,int* nbColOut);
extern double* getValues(int *numberOfRow, int *numberOfCol);
}

