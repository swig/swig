// Tests typedef through function pointers

%module typedef_funcptr
%{
int addf(int x, int y) {
   return x+y;
}
int subf(int x, int y) {
   return x-y;
}
%}

%inline %{
typedef int Integer;

Integer do_op(Integer x, Integer y, Integer (*op)(Integer, Integer)) {
    return (*op)(x,y);
}
%}

%constant int     addf(int x, int y);
%constant Integer subf(Integer x, Integer y);
