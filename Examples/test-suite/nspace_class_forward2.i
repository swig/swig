%module nspace_class_forward2

%nspace;

%inline %{
  namespace NS {
    class Foo;
    struct Garga {
      int a;
    };
    int fn(Foo *f);
  }
%}

%inline %{

class NS::Foo
{
  int m;
public:
  Foo(int i) : m(i) {}
  int get_m() { return m;}
};

int NS::fn(NS::Foo *f) {
  return f->get_m();
}
%}
