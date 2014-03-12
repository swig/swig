%module scilab_li_matrix

%include matrix.i

%define %use_matrix_apply(TYPE...)
%apply (TYPE *matrixIn, int matrixInRowCount, int matrixInColCount) { (TYPE *inputMatrix, int nbRow, int nbCol) }
%apply (TYPE **matrixOut, int *matrixOutRowCount, int *matrixOutColCount) { (TYPE **resultMatrix, int *nbRowRes, int *nbColRes) }
%enddef

%use_matrix_apply(int);
%use_matrix_apply(double);
%use_matrix_apply(char *);
%use_matrix_apply(bool);

%inline %{

// int and double matrix functions
template<typename T> T in_matrix_func(T *inputMatrix, int nbRow, int nbCol) {
  T sum = 0;
  int i;
  for (i=0; i<nbRow*nbCol; i++)
    sum += inputMatrix[i];
  return sum;
}

template<typename T> void out_matrix_func(T **resultMatrix, int *nbRowRes, int *nbColRes) {
  int size;
  int i;
  *nbRowRes = 3;
  *nbColRes = 2;
  size = (*nbRowRes) * (*nbColRes);
    *resultMatrix = (T*) malloc(size * sizeof(T));
  for (i=0; i<size; i++)
    (*resultMatrix)[i] = i;
}

template<typename T> void inout_matrix_func(T *inputMatrix, int nbRow, int nbCol, T **resultMatrix, int *nbRowRes, int *nbColRes) {
  int i;
  int size = nbRow * nbCol;
  *nbRowRes = nbRow;
  *nbColRes = nbCol;
  *resultMatrix = (T*) malloc(size * sizeof(T));
  for (i=0; i<size; i++) {
    (*resultMatrix)[i] = inputMatrix[i] * inputMatrix[i];
  }
}

// char* matrix functions
template<> char* in_matrix_func(char **inputMatrix, int nbRow, int nbCol) {
  char *s = (char *) malloc(nbRow * nbCol * sizeof(char) + 1);
  int i;
  for (i=0; i<nbRow*nbCol; i++)
    strcat(s, inputMatrix[i]);
  return s;
}

template<> void out_matrix_func(char ***resultMatrix, int *nbRowRes, int *nbColRes) {
  int size;
  char *s;
  int i;
  *nbRowRes = 3;
  *nbColRes = 2;
  size = (*nbRowRes) * (*nbColRes);
  *resultMatrix = (char **) malloc(size * sizeof(char *));
  for (i=0; i<size; i++) {
    s = (char *) malloc(sizeof(char)+1);
    sprintf(s, "%c", char(65 + i));
    (*resultMatrix)[i] = s;
  }
}

template<> void inout_matrix_func(char **inputMatrix, int nbRow, int nbCol, char ***resultMatrix, int *nbRowRes, int *nbColRes) {
  int i;
  char *s;
  int size = nbRow * nbCol;
  *nbRowRes = nbRow;
  *nbColRes = nbCol;
  *resultMatrix = (char **) malloc(size * sizeof(char* ));
  for (i=0; i<size; i++) {
    s = (char *) malloc((2 * strlen(inputMatrix[i]) + 1) * sizeof(char));
    sprintf(s, "%s%s", inputMatrix[i], inputMatrix[i]);
    (*resultMatrix)[i] = s;
  }
}

// bool matrix functions
template<> bool in_matrix_func(bool *inputMatrix, int nbRow, int nbCol) {
  bool b = true;
  int i;
  b = inputMatrix[0];
  for (i=1; i<nbRow*nbCol; i++)
    b = b ^ inputMatrix[i];
  return b;
}

template<> void out_matrix_func(bool **resultMatrix, int *nbRowRes, int *nbColRes) {
  int size;
  int i;
  *nbRowRes = 3;
  *nbColRes = 2;
  size = (*nbRowRes) * (*nbColRes);
  *resultMatrix = (bool*) malloc(size * sizeof(bool));
  for (i=0; i<size; i++) {
    (*resultMatrix)[i] = i % 2 == 0;
  }
}

template<> void inout_matrix_func(bool *inputMatrix, int nbRow, int nbCol, bool **resultMatrix, int *nbRowRes, int *nbColRes) {
  int i;
  int size = nbRow * nbCol;
  *nbRowRes = nbRow;
  *nbColRes = nbCol;
  *resultMatrix = (bool*) malloc(size * sizeof(bool));
  for (i=0; i<size; i++) {
    (*resultMatrix)[i] = inputMatrix[i]==1?0:1;
  }
}
%}

%define %instantiate_matrix_template_functions(NAME, TYPE...)
%template(in_ ## NAME ## _matrix_func) in_matrix_func<TYPE>;
%template(out_ ## NAME ## _matrix_func) out_matrix_func<TYPE>;
%template(inout_ ## NAME ## _matrix_func) inout_matrix_func<TYPE>;
%enddef

%instantiate_matrix_template_functions(int, int);
%instantiate_matrix_template_functions(double, double);
%instantiate_matrix_template_functions(charptr, char *);
%instantiate_matrix_template_functions(bool, bool);






