%module matrixlib
%include "matrix.i" 
extern double sumitems(double *, int, int);
%typemap (in) (int *numberOfRow, int *numberOfCol) {
  $1 = &iRowsOut;
  $2 = &iColsOut;
}

%inline {
extern double sumitems(double *first, int nbRow, int nbCol);
extern double* getValues(int *numberOfRow, int *numberOfCol);
}

