%module ocaml_carray

%include <carray.i>

// The 'in' typemaps used to allocate one byte per array element and overflow the heap
%inline %{
int sum_ints(int a[8]) {
  int i, sum = 0;
  for (i = 0; i < 8; i++)
    sum += a[i];
  return sum;
}

double sum_doubles(double a[4]) {
  return a[0] + a[1] + a[2] + a[3];
}
%}
