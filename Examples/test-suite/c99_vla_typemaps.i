/* Typemaps for C99 variable length array parameters that use the sizes the arrays have at runtime */
%module c99_vla_typemaps

%{
/* C++ and C before C99 reject variable length arrays, so their compilers see only the plain definitions */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L && !defined(__cplusplus) && !defined(__STDC_NO_VLA__)
#define TEST_C99_VLA
#endif

/* The sizes each check typemap saw */
static int seen[3];
%}

%inline %{
int seen_size(int i) { return seen[i]; }
%}

// Multi-argument typemaps written with '[*]', or a size naming an earlier parameter, only match variable length arrays

%typemap(check) (int n, int a[*]) "seen[0] = $2_dim0;"
%typemap(check) (int n, int a[]) "seen[0] = -1;"
%typemap(check) (int m, long b[m]) "seen[0] = $2_dim0;"
%typemap(check) (int n, double x[*], double y[*]) "seen[0] = $2_dim0; seen[1] = $3_size;"

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void multi_star(int n, int a[n]);
void multi_named(int m, long b[m]);
void multi_pair(int n, double x[n], double y[n]);
#endif
void multi_plain(int n, int a[]);
%}

%{
void multi_star(int n, int *a) { (void)n; (void)a; }
void multi_named(int m, long *b) { (void)m; (void)b; }
void multi_pair(int n, double *x, double *y) { (void)n; (void)x; (void)y; }
void multi_plain(int n, int *a) { (void)n; (void)a; }
%}

// Each variable length array dimension has its runtime size while any other dimension also matches ANY

%typemap(check) double [*][*] "seen[0] = $1_dim0; seen[1] = $1_dim1; seen[2] = $1_size;"
%typemap(check) double [3][*] "seen[0] = $1_dim0; seen[1] = $1_dim1; seen[2] = $1_size;"
%typemap(check) int [*][ANY] "seen[0] = $1_dim0; seen[1] = $1_dim1; seen[2] = $1_size;"

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void grid(int rows, int cols, double m[rows][cols]);
void three_rows(int cols, double m[3][cols]);
void four_columns(int rows, int m[rows][4]);
#endif
%}

%{
#if defined(TEST_C99_VLA)
void grid(int rows, int cols, double m[rows][cols]) { (void)rows; (void)cols; (void)m; }
void three_rows(int cols, double m[3][cols]) { (void)cols; (void)m; }
void four_columns(int rows, int m[rows][4]) { (void)rows; (void)m; }
#else
void grid(int rows, int cols, const void *m) { (void)rows; (void)cols; (void)m; }
void three_rows(int cols, const void *m) { (void)cols; (void)m; }
void four_columns(int rows, const void *m) { (void)rows; (void)m; }
#endif
%}

// %apply and %clear with a multi-argument typemap written with '[*]'

%typemap(check) (int n, unsigned a[*]) "seen[0] = $2_dim0;"
%typemap(check) unsigned [] "seen[0] = -1;"
%apply (int n, unsigned a[*]) { (int count, unsigned values[count]) }

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void applied(int count, unsigned values[count]);
#endif
%}

%clear (int count, unsigned values[*]);

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void cleared(int count, unsigned values[count]);
#endif
%}

%{
void applied(int count, unsigned *values) { (void)count; (void)values; }
void cleared(int count, unsigned *values) { (void)count; (void)values; }
%}

// A typemap written with '[*]' is used before one for an array of unknown size with more qualifiers or typedefs

%typemap(check) int [*] "seen[0] = $1_dim0;"
%typemap(check) const int [] "seen[0] = -1;"
%typemap(check) short [*] "seen[0] = $1_dim0;"

%inline %{
typedef short myshort;
%}

%typemap(check) myshort [] "seen[0] = -1;"

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void const_ints(int len, const int a[len]);
void my_shorts(int len, myshort a[len]);
#endif
%}

%{
void const_ints(int len, const int *a) { (void)len; (void)a; }
void my_shorts(int len, myshort *a) { (void)len; (void)a; }
%}

// The default typemap 'SWIGTYPE [*]' is used before 'SWIGTYPE []'

%typemap(check) SWIGTYPE [*] "seen[0] = $1_dim0;"
%typemap(check) SWIGTYPE [] "seen[0] = -1;"

%inline %{
struct Point {
  int x;
  int y;
};
#if defined(SWIG) || defined(TEST_C99_VLA)
void points(int len, struct Point pts[len]);
#endif
%}

%{
void points(int len, struct Point *pts) { (void)len; (void)pts; }
%}

// The type variables give the type the array is wrapped as, without the '*'

%{
static const char *type_seen = "";
%}

%typemap(check) float [*] %{ type_seen = "$1_type $&1_type"; %}

%inline %{
const char *seen_type(void) { return type_seen; }
#if defined(SWIG) || defined(TEST_C99_VLA)
void floats(int len, float a[len]);
#endif
%}

%{
void floats(int len, float *a) { (void)len; (void)a; }
%}

// A multi-argument typemap with array sizes that are members of an earlier structure parameter

%typemap(check) (struct Dims d, long m[d.rows][d.cols]) "seen[0] = $2_dim0 * 10 + $2_dim1;"

%inline %{
struct Dims {
  int rows;
  int cols;
};
#if defined(SWIG) || defined(TEST_C99_VLA)
void member_sizes(struct Dims d, long m[d.rows][d.cols]);
#endif
%}

%{
#if defined(TEST_C99_VLA)
void member_sizes(struct Dims d, long m[d.rows][d.cols]) { (void)d; (void)m; }
#else
void member_sizes(struct Dims d, const void *m) { (void)d; (void)m; }
#endif
%}

// Typemaps written with a typedef name, for an element type that is a typedef of a number or of an array

%inline %{
typedef long vla_long_t;
typedef double Row[3];
%}

%typemap(check) vla_long_t[*] "seen[0] = $1_dim0;"
%typemap(check) Row[*] "seen[0] = $1_dim0; seen[1] = $1_dim1; seen[2] = $1_size;"

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void typedef_longs(int n, vla_long_t a[n]);
void typedef_rows(int n, Row m[n]);
#endif
%}

%{
void typedef_longs(int n, vla_long_t *a) { (void)n; (void)a; }
void typedef_rows(int n, Row *m) { (void)n; (void)m; }
%}

// A typemap written with the size as declared is used before one written with '[*]' and has the runtime size too

%typemap(check) const double values[n] "seen[0] = $1_dim0; seen[1] = 1;"
%typemap(check) const double [n] "seen[0] = $1_dim0; seen[1] = 2;"
%typemap(check) const double values[*], const double numbers[*] "seen[0] = $1_dim0; seen[1] = 3;"
%typemap(check) (double data[n], int scale) "seen[0] = $1_dim0; seen[1] = $2;"
%typemap(check) int (*row)[n] "seen[1] = 4;"

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
void declared_named(int n, const double values[n]);
void declared_unnamed(int n, const double numbers[n]);
void declared_other(int k, const double values[k]);
void declared_multi(int n, double data[n], int scale);
void declared_pointer(int n, int (*row)[n]);
#endif
%}

%{
void declared_named(int n, const double *values) { (void)n; (void)values; }
void declared_unnamed(int n, const double *numbers) { (void)n; (void)numbers; }
void declared_other(int k, const double *values) { (void)k; (void)values; }
void declared_multi(int n, double *data, int scale) { (void)n; (void)data; (void)scale; }
#if defined(TEST_C99_VLA)
void declared_pointer(int n, int (*row)[n]) { (void)n; (void)row; }
#else
void declared_pointer(int n, const void *row) { (void)n; (void)row; }
#endif
%}

// An 'in' typemap with numinputs=0 at the start, in the middle and at the end comes after the earlier arguments are converted

%typemap(in, numinputs=0) int start "$1 = 100;"
%typemap(in, numinputs=0) int middle[*], int end[*] {
  int i;
  $1 = (int *)malloc((size_t)$1_dim0 * sizeof(int));
  for (i = 0; i < $1_dim0; i++) {
    $1[i] = 1;
  }
}
%typemap(freearg) int middle[*], int end[*] "free($1);"

#ifdef SWIGC
// The C target language uses neither these nor a multi-argument 'ctype' typemap when wrapping C, so declares every parameter
%typemap(ctype) (int start, int n) "int"
#endif

%inline %{
#if defined(SWIG) || defined(TEST_C99_VLA)
int ignored_arguments(int start, int n, int middle[n], int scale, int end[n]);
#endif
%}

%{
#include <stdlib.h>

static int sum(int n, const int *a) {
  int total = 0;
  int i;
  for (i = 0; i < n; i++) {
    total += a[i];
  }
  return total;
}
int ignored_arguments(int start, int n, int *middle, int scale, int *end) { return start + scale * sum(n, middle) + sum(n, end); }
%}
