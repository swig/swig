%module typedef_reference

%inline %{
  typedef int & IntRef;
  int somefunc(IntRef i) { return i; }
  int otherfunc(int &i) { return i; }
%}
