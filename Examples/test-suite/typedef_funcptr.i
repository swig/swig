// Tests typedef through function pointers

%module typedef_funcptr

%warnfilter(801) addf; /* Ruby, wrong constant name */
%warnfilter(801) subf; /* Ruby, wrong constant name */

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

extern "C"
Integer do_op(Integer x, Integer y, Integer (*op)(Integer, Integer)) {
    return (*op)(x,y);
}
%}

%constant int     addf(int x, int y);
%constant Integer subf(Integer x, Integer y);
