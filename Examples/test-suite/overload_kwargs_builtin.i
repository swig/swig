%module overload_kwargs_builtin

%feature("kwargs");

%inline %{
int bfoo(int x) { return x; }
int bfoo(int x, int y) { return x + y; }
%}
