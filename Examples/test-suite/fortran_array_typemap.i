/* File: fortran_array_typemap.i */
%module fortran_array_typemap

%include <typemaps.i>

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


