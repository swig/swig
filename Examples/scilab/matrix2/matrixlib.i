%module matrixlib

%include matrix.i

%apply (double *matrixIn, int matrixInRowCount, int matrixInColCount) { (double *inputMatrix, int nbRow, int nbCol) }
%apply (double **matrixOut, int *matrixOutRowCount, int *matrixOutColCount) { (double **resultMatrix, int *nbRowRes, int *nbColRes) }

%apply (int *matrixIn, int matrixInRowCount, int matrixInColCount) { (int *inputMatrix, int nbRow, int nbCol) }
%apply (int **matrixOut, int *matrixOutRowCount, int *matrixOutColCount) { (int **resultMatrix, int *nbRowRes, int *nbColRes) }

%apply (char **matrixIn, int matrixInSize) { (char **inputVector, int size) }
%apply (char ***matrixOut, int *matrixOutSize) { (char ***resultVector, int *sizeRes) }

%inline %{
  extern double sumDoubleMatrix(double *inputMatrix, int nbRow, int nbCol);
  extern void squareDoubleMatrix(double *inputMatrix, int nbRow, int nbCol, double **resultMatrix, int *nbRowRes, int *nbColRes);
  extern void getDoubleMatrix(double **resultMatrix, int *nbRowRes, int *nbColRes);

  extern int sumIntegerMatrix(int *inputMatrix, int nbRow, int nbCol);
  extern void squareIntegerMatrix(int *inputMatrix, int nbRow, int nbCol, int **resultMatrix, int *nbRowRes, int *nbColRes);
  extern void getIntegerMatrix(int **resultMatrix, int *nbRowRes, int *nbColRes);

  extern char* concatStringVector(char **inputVector, int size);
  extern void getStringVector(char ***resultVector, int *sizeRes);
%}

