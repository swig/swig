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
  int i, j;
  for (i = 0; i < 3; ++i) {
    for (j = 0; j < 2; ++j) {
      result += inp[i][j];
    }
  }
  return result;
}
%}

/* Test variable-size arguments */

%apply SWIGTYPE ARRAY[] { const double* inp, const double inpv[] };

%inline %{
double cpp_dynamic_sum(int count, const double *inp) {
  const double *end = inp + count;
  const double *v;
  double value = 0;
  for (v = inp; v != end; ++v) {
    value += *v;
  }
  return value;
}

double cpp_dynamic_sum_arr(int inpc, const double inpv[]) {
  return cpp_dynamic_sum(inpc, inpv);
}
%}

/* Test mixed fixed/variable size */

%apply SWIGTYPE ARRAY[][ANY] { const double points[][3] };
%apply SWIGTYPE ARRAY[ANY] { double avg[3] };

%inline %{
void average_points(int count, const double points[][3], double avg[3]) {
  int i, j;
  double norm;
  avg[0] = avg[1] = avg[2] = 0.0;
  for (i = 0; i < count; ++i) {
    for (j = 0; j < 3; ++j) {
      avg[j] += points[i][j];
    }
  }

  norm = 1.0 / (double)count;
  for (j = 0; j < 3; ++j) {
    avg[j] *= norm;
  }
}
%}

