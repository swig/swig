/* C99 array parameters: static and type qualifiers in the brackets and variable length arrays, which SWIG wraps as plain arrays */
%module c99_parameter_array_declarators

%{
/* C++, C before C99 and MSVC reject this syntax, so their compilers see only the plain definitions */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L && !defined(__cplusplus) && !defined(_MSC_VER)
#define TEST_C99_ARRAY_DECLARATORS
#endif

static int add_n(int n, const int *a) {
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += a[i];
  }
  return sum;
}
%}

%inline %{
int *three_numbers(void) {
  static int numbers[] = {1, 2, 3};
  return numbers;
}
%}

// Static and type qualifiers in parameter array declarators

/* Matches only if 'static' and the pointer qualifiers are dropped and the dimension kept */
%rename(sum_qualified) sum_static_const(const int [3]);
/* Matches when written as declared */
%rename(sum_static_renamed) sum_static(int a[static 3]);

%inline %{
#if defined(SWIG) || defined(TEST_C99_ARRAY_DECLARATORS)
int sum_static(int a[static 3]);
int sum_const(int a[const 3]);
int sum_static_const(const int a[static const 3]);
int sum_const_static(int a[const static 3]);
int sum_qualifiers(int a[const volatile restrict 3]);
int sum_qualifiers_only(int a[const]);
int sum_unnamed(int [static 3]);
int sum_pointers(int *a[static 2]);
int sum_grid(int a[static 2][3]);
typedef int (*summer)(const int a[static 3]);
#endif
%}

%{
int sum_static(int a[3]) { return add_n(3, a); }
int sum_const(int a[3]) { return add_n(3, a); }
int sum_static_const(const int a[3]) { return add_n(3, a); }
int sum_const_static(int a[3]) { return add_n(3, a); }
int sum_qualifiers(int a[3]) { return add_n(3, a); }
int sum_qualifiers_only(int a[]) { return add_n(3, a); }
int sum_unnamed(int a[3]) { return add_n(3, a); }
int sum_pointers(int *a[2]) { return *a[0] + *a[1]; }
int sum_grid(int a[2][3]) { return a[0][0] + a[1][2]; }
%}

// Variable length array type, the size being an earlier parameter in the parameter list

/* Matches only if the variable length array's size is dropped */
%rename(sum_n_renamed) sum_n(int, const int []);
/* Matches when written as declared */
%rename(sum_n_static_renamed) sum_n_static(int n, const int a[static n]);

%inline %{
#if defined(SWIG) || (defined(TEST_C99_ARRAY_DECLARATORS) && !defined(__STDC_NO_VLA__))
int sum_n(int n, const int a[n]);
int sum_n_static(int n, const int a[static n]);
int char_length(int n, const char s[n]);
#endif
%}

%{
int sum_n(int n, const int *a) { return add_n(n, a); }
int sum_n_static(int n, const int *a) { return add_n(n, a); }
int char_length(int n, const char *s) {
  int i = 0;
  while (i < n && s[i]) {
    i++;
  }
  return i;
}
%}

// Variable length array type of unspecified size

%rename(sum_n_unsized_renamed) sum_n_unsized(int n, const int a[*]);

%inline %{
#if defined(SWIG) || (defined(TEST_C99_ARRAY_DECLARATORS) && !defined(__STDC_NO_VLA__))
int sum_n_unsized(int n, const int a[*]);
int sum_n_unnamed(int, const int [const *]);
#endif
%}

%{
int sum_n_unsized(int n, const int *a) { return add_n(n, a); }
int sum_n_unnamed(int n, const int *a) { return add_n(n, a); }
%}

// Variably modified types: variable length arrays inside an array, a pointer or a function pointer's parameters

%inline %{
#if defined(SWIG) || (defined(TEST_C99_ARRAY_DECLARATORS) && !defined(__STDC_NO_VLA__))
double trace(int n, double m[n][n]);
double trace_unsized(int n, double m[*][*]);
int first_row_sum(int n, int (*rows)[n]);
int apply_sum(int n, int (*f)(const int a[n]), const int numbers[n]);
#endif
%}

%{
#if defined(TEST_C99_ARRAY_DECLARATORS) && !defined(__STDC_NO_VLA__)
double trace(int n, double m[n][n]) {
  double sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += m[i][i];
  }
  return sum;
}
double trace_unsized(int n, double m[n][n]) { return trace(n, m); }
int first_row_sum(int n, int (*rows)[n]) { return add_n(n, rows[0]); }
int apply_sum(int n, int (*f)(const int a[n]), const int numbers[n]) { return n > 0 ? f(numbers) : 0; }
#else
/* A pointer to an array of unknown size converts to 'const void *' in C++ too */
double trace(int n, const void *m) {
  const double *elements = (const double *)m;
  double sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += elements[i * n + i];
  }
  return sum;
}
double trace_unsized(int n, const void *m) { return trace(n, m); }
int first_row_sum(int n, const void *rows) { return add_n(n, (const int *)rows); }
int apply_sum(int n, int (*f)(const int *a), const int *numbers) { return n > 0 ? f(numbers) : 0; }
#endif
%}
