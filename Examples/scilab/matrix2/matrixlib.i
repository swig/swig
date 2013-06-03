%module matrixlib

%include matrix.i

%apply (double *matrixAsInput, int rows, int cols) { (double *inputMatrix, int nbRow, int nbCol) }
%apply (double **matrixAsOutput, int *rows, int *cols) { (double **resultMatrix, int *nbRowRes, int *nbColRes) }


%inline
{
  extern double sumMatrixElements(double *inputMatrix, int nbRow, int nbCol);
  extern void squareMatrixElements(double *inputMatrix, int nbRow, int nbCol, double **resultMatrix, int *nbRowRes, int *nbColRes);
  extern void getMatrix(double **resultMatrix, int *nbRowRes, int *nbColRes);
}

