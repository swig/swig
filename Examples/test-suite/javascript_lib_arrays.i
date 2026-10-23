%module javascript_lib_arrays

%include <arrays_javascript.i>

%apply int[] { int *data1 }
%apply int[3] { int data2[3] }
%apply int[4] { int data3[4] }
%apply int[] { int *nullable }
%apply int[3] { int nullable_sized[3] }

%inline %{

int sum1(int *data1, int size) {
  int sum = 0;
  for (int i = 0; i < size; i++) {
    sum += data1[i];
  }
  return sum;
}

int sum2(int data2[3]) {
  int sum = 0;
  for (int i = 0; i < 3; i++) {
    sum += data2[i];
  }
  return sum;
}

int data3[4] = {1, 2, 3, 4};

int isnull(int *nullable) { return nullable == 0; }
int isnull_sized(int nullable_sized[3]) { return nullable_sized == 0; }

%}

