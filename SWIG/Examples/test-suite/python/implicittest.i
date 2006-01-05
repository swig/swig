%module(naturalvar="1") implicittest

%implicitconv;

%inline 
{
  struct B { };  
}

%inline 
{
  struct A
  {
    int ii;
    A(int i) { ii = 1; }
    A(double d) { ii = 2; }
    A(const B& b) { ii = 3; }
    explicit A(char *s) { ii = 4; }

    int get() const { return ii; }
    
  };

  int get(const A& a) { return a.ii; }

  template <class T>
  struct A_T
  {
    int ii;
    A_T(int i) { ii = 1; }
    A_T(double d) { ii = 2; }
    A_T(const B& b) { ii = 3; }
    explicit A_T(char *s) { ii = 4; }

    int get() const { return ii; }
    
  };
}

%inline 
{
  struct Foo 
  {
    int ii;
    Foo(){ ii = 0;}
    Foo(int){ ii = 1;}
    Foo(double){ ii = 2;}
    explicit Foo(char *s){ii = 3;}
    Foo(const Foo& f){ ii = f.ii;}
    
  };

  struct Bar 
  {
    int ii;
    Foo f;
    Bar() {ii = -1;}
    Bar(const Foo& f){ ii = f.ii;}
  };


  int get_b(const Bar&b) { return b.ii; }
  
  Foo foo;
  
}

%template(A_int) A_T<int>;
