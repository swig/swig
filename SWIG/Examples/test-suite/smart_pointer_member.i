%module smart_pointer_member


%extend Foo
{
  int extension(int i, int j) { return i; }
  int extension(int i) { return i; }
  int extension() { return 1; }
}

%inline %{

  class Foo {
  public:
    int x[4];
    int y;
    static const int z;
  };
  
  class Bar {
    Foo *f;
  public:
    Bar(Foo *f) : f(f) { }
    Foo *operator->() {
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
%}
