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

struct CarrayItem {
  int value;
};

int sum_items(CarrayItem a[2]) {
  return a ? a[0].value + a[1].value : -1;
}

struct CarrayMember {
  int ints[8];
};
%}
