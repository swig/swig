%module("nocastmode") li_implicit
#pragma SWIG nowarn=204
%include implicit.i

%inline 
{
  struct B { };  
}

%implicit(A, int, double, B);

%inline 
{
  struct A
  {
    int ii;
    A(int i) { ii = 1; }
    A(double d) { ii = 2; }
    A(const B& b) { ii = 3; }
  };

  int get(const A& a) { return a.ii; }
}
