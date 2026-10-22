/* The fixed size array typemaps of the opt-in array libraries used for C99 variable length array parameters */
%module c99_vla_array_libraries

#if defined(SWIGJAVA)
%include <arrays_java.i>
JAVA_ARRAYSOFCLASSES(struct Item)
%apply ARRAYSOFENUMS[ANY] { enum Colour[*] }
#elif defined(SWIGJAVASCRIPT)
%include <arrays_javascript.i>
#elif defined(SWIGOCAML)
%include <carray.i>
#endif

%{
/* C++ and C before C99 reject variable length arrays, so their compilers see only the plain definitions */
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L && !defined(__cplusplus) && !defined(__STDC_NO_VLA__)
#define TEST_C99_VLA
#endif
%}

%inline %{
enum Colour { RED, GREEN, BLUE };

struct Item {
  int value;
};

#if defined(SWIG) || defined(TEST_C99_VLA)
int sum_ints(int n, const int values[n]);
double sum_doubles(int n, const double values[n]);
void double_ints(int n, int numbers[n]);
int sum_colours(int n, enum Colour colours[n]);
int sum_const_colours(int n, const enum Colour colours[n]);
int sum_items(int n, struct Item items[n]);
int sum_item_pointers(int n, struct Item *pointers[n]);
int count_names(int n, char *names[n]);
#endif
%}

%{
int sum_ints(int n, const int *values) {
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += values[i];
  }
  return sum;
}

double sum_doubles(int n, const double *values) {
  double sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += values[i];
  }
  return sum;
}

void double_ints(int n, int *numbers) {
  int i;
  for (i = 0; i < n; i++) {
    numbers[i] *= 2;
  }
}

int sum_colours(int n, enum Colour *colours) {
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += (int)colours[i];
  }
  return sum;
}

int sum_const_colours(int n, const enum Colour *colours) {
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += (int)colours[i];
  }
  return sum;
}

int sum_items(int n, struct Item *items) {
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += items[i].value;
  }
  return sum;
}

int sum_item_pointers(int n, struct Item **pointers) {
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += pointers[i]->value;
  }
  return sum;
}

int count_names(int n, char **names) {
  int count = 0;
  int i;
  for (i = 0; i < n; i++) {
    if (names[i]) {
      count++;
    }
  }
  return count;
}
%}
