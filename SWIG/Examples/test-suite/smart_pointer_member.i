%module smart_pointer_member



%inline %{

  class Foo {
  public:
    int x[4];
    int y;
    static const int z;
    static const int zz = 3;
    static int zx;

    static int boo() { return 0;}
  };
  
  class Bar {
    Foo *f;
  public:
    Bar(Foo *f) : f(f) { }
    Foo *operator->() {
      return f;
    }

    static int bua() { return 0;}
  };

  class CBar {
    Foo *f;
  public:
    CBar(Foo *f) : f(f) { }
    Foo *operator->() const {
      return f;
    }
  };

  
  int get_y(Bar *b) 
  {
    return (*b)->y;
  }
  
  int get_z(Bar *b) 
  {
    return (*b)->z;
  }
%}


%{
  const int Foo::z = 3;
  const int Foo::zz;
  int Foo::zx;
%}
