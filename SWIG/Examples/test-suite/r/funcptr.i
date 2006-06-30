%module funcptr

/*
  Works if we use the typedef or the inline function pointer.
        int (*op)(int i,int j));  
*/


/*
typedef struct B (*Bar)(int i, struct C a);
typedef struct A *(*Foo)(int i, struct B a);

*/


/*
 Complicated one that should defeat just reading , to find
 the number of arguments expected in the function pointer.
extern void do(int (*op)(int (*i)(double, double), int j)); 
*/

%inline %{
typedef double (*DistFun)(double* data, int r, int c, int i, int j, 
			  void *xdata);

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

int (*funcvar)(int,int) = add;
%}