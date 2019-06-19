/* File: fortran_array_typemap.i */
%module fortran_array_typemap

%include <typemaps.i>

/* Test combination pointer/size arguments */

%apply (SWIGTYPE *DATA, size_t SIZE)       { (int *DATA, size_t SIZE) };
%apply (const SWIGTYPE *DATA, size_t SIZE) { (const int *DATA, size_t SIZE) };
%apply (const SWIGTYPE *DATA, size_t SIZE) { (double *DATA, int SIZE) };

%inline %{
void set_values_int(int *DATA, size_t SIZE, int value) {
  int *end = DATA + SIZE;
  int *v = DATA;
  for (v = DATA; v != end; ++v) {
    *v = value;
  }
}

void set_values_dbl(double *DATA, int SIZE, double value) {
  double *end = DATA + SIZE;
  double *v;
  for (v = DATA; v != end; ++v) {
    *v = value;
  }
}

int accum(const int *DATA, size_t SIZE) {
  int result = 0;
  const int *end = DATA + SIZE;
  const int *v;
  for (v = DATA; v != end; ++v) {
    result += *v;
  }
  return result;
}

%}

/* Test fixed-size arguments */

%apply SWIGTYPE ARRAY[ANY] { int global[4] };
%apply SWIGTYPE ARRAY[ANY][ANY] { double[ANY][ANY] };

%inline %{
int global[4] = {0,0,0,0};

double cpp_sum(const double inp[3][2]) {
  double result = 0;
  for (int i = 0; i < 3; ++i) {
    for (int j = 0; j < 2; ++j) {
      result += inp[i][j];
    }
  }
  return result;
}
%}

