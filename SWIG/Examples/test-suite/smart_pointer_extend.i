%module smart_pointer_extend

%inline %{

class CBase
{
};

class CDerived : public CBase
{
};

class CPtr
{
public:
    CDerived* operator->(void) {return 0;};
};

%}

%extend CBase {
  int foo(void) {return 1;};
}

%extend CDerived {
  int foo(void) {return 2;};
}


%extend Foo
{
  int extension(int i, int j) { return i; }
  int extension(int i) { return i; }
  int extension() { return 1; }
}

%inline %{
  struct Foo {
  };
  
  class Bar {
    Foo *f;
  public:
    Bar(Foo *f) : f(f) { }
    Foo *operator->() {
      return f;
    }
  };
%}

