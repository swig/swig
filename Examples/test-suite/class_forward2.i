%module class_forward2

%inline %{
  class Foo;
  int fn(Foo *f);
%}

%inline %{

class Foo
{
  int m;
public:
  Foo(int i) : m(i) {}
  int get_m() { return m;}
};

int fn(Foo *f) {
  return f->get_m();
}
%}
