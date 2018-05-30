%module fortran_funptr

%inline %{
typedef int (*BinaryOp)(int, int);

int do_op(int a, int b, BinaryOp op) {
  return (*op)(a, b);
}

int add(int a, int b) {
  return a + b;
}
%}

%constant BinaryOp ADD_FP = add;
