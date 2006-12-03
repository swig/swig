/* File : example.i */
%module double_delete

%inline %{

class Foo {
private:
  double r;
public:
  Foo(double rin) : r(rin) {}; 
};
%}



