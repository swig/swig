%module smart_pointer_extend

%inline %{
  namespace hi
  {
    struct CBase
    {
      static int hello() 
      {
	return 1;
      }      
    };

    class CDerived : public CBase
    {
    };

    class CPtr
    {
    public:
      CDerived* operator->(void) {return 0;};
    };

    int get_hello(CPtr ptr)
    {
      return ptr->hello();
    }

    class CPtrConst
    {
    public:
      CDerived* operator->(void) const {return 0;};
    };
    
  }
  
%}

%extend hi::CBase {
  int foo(void) {return 1;};
  int bar(void) {return 2;};
  int boo(int i) {return i;};
}

%extend hi::CDerived {
  int foo(void) {return 1;};
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



%extend CFoo
{
public:
    static void StatFun() {};
    static void StatFun(int i) {};

    static void HoHoHo(int i, int j) {};
}

%inline %{

class CFoo
{
};

class CPtrFoo
{
public:
    CFoo* operator->(void) {return 0;};
};

%}


