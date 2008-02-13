%module funcptr

/*
 Complicated one that should defeat just reading , to find
 the number of arguments expected in the function pointer.
extern void do(int (*op)(int (*i)(double, double), int j)); 
*/

%inline %{
typedef double (*DistFun)(double* data, int r, int c, int i, int j, void *xdata);

void distance(double *data, int *dim, DistFun fun,  double *output) {
}

typedef int (*Operator)(int i,int j);

int do_op(int a, int b, int (*op)(int,int)) {
  return (*op)(a,b);
}

int add(int a, int b) {
  return a+b;
}

int sub(int a, int b) {
  return a-b;
}

int mul(int a, int b) {
  return a*b;
}

int *nowt() { 
  return 0;
}

int (*funcvar)(int,int) = add;
int * (*funcvar2)() = nowt;
int * (*funcvar3)(void) = nowt;
%}
