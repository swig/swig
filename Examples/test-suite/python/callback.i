%module callback

%pythoncallback(1);
%pythoncallback(1) foo;
%pythoncallback(1) A::bar;
%pythoncallback(1) A::foom;
%pythoncallback(1) foo_T;

%inline %{


  int foo(int a) {
    return a;
  }
  
  struct A 
  {
    static int bar(int a) {
      return 2*a;
    }

    int foom(int a) 
    {
      return -a;
    }

    friend int foof(int a) 
    {
      return 3*a;
    }    
  };
  

  int foobar(int a, int (*pf)(int a)) {
    return pf(a);
  }

  int foobarm(int a, A ap, int (A::*pf)(int a)) {
    return (ap.*pf)(a);
  }

  template <class T>
    T foo_T(T a) 
    {
      return a;
    }

  template <class T>
    T foo_T(T a, T b) 
    {
      return a + b;
    }


  template <class T>
  T foobar_T(T a, T (*pf)(T a)) {
    return pf(a);
  }

  template <class T>
  const T& ident(const T& x) {
    return x;
  }
%}

%template(foo_i) foo_T<int>;
%template(foobar_i) foobar_T<int>;

%template(foo_d) foo_T<double>;
%template(foobar_d) foobar_T<double>;

%template(ident_d) ident<double>;
