%module ocaml_carray

%include <carray.i>

// The 'in' typemaps used to allocate one byte per array element and overflow the heap; -1 is returned for NULL
%inline %{
int sum_ints(int a[8]) {
  int i, sum = 0;
  if (!a)
    return -1;
  for (i = 0; i < 8; i++)
    sum += a[i];
  return sum;
}

double sum_doubles(double a[4]) {
  return a ? a[0] + a[1] + a[2] + a[3] : -1;
}

int sum_schars(signed char a[4]) {
  return a[0] + a[1] + a[2] + a[3];
}

int sum_uchars(unsigned char a[4]) {
  return a[0] + a[1] + a[2] + a[3];
}

typedef struct CarrayItem {
  int value;
} CarrayItem;

int sum_items(CarrayItem a[2]) {
  return a ? a[0].value + a[1].value : -1;
}

typedef struct CarrayMember {
  int ints[8];
} CarrayMember;
%}

// An array of unknown size has as many elements as the OCaml array
%inline %{
typedef enum CarrayColor { CARRAY_RED = 1, CARRAY_GREEN = 2, CARRAY_BLUE = 4 } CarrayColor;

int sum_ints_unknown_size(int a[], int n) {
  int i;
  int sum = 0;
  if (!a)
    return -1;
  for (i = 0; i < n; i++)
    sum += a[i];
  return sum;
}

double sum_doubles_unknown_size(const double a[], int n) {
  int i;
  double sum = 0;
  for (i = 0; i < n; i++)
    sum += a[i];
  return sum;
}

int sum_items_unknown_size(const CarrayItem a[], int n) {
  int i;
  int sum = 0;
  if (!a)
    return -1;
  for (i = 0; i < n; i++)
    sum += a[i].value;
  return sum;
}

int sum_colors_unknown_size(CarrayColor a[], int n) {
  int i;
  int sum = 0;
  if (!a)
    return -1;
  for (i = 0; i < n; i++)
    sum += a[i];
  return sum;
}
%}
