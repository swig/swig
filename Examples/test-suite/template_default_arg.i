%module template_default_arg

%warnfilter(801) Hello;	/* Ruby, wrong class name */

%inline %{
  template <class T>
    struct Foo 
    {
      typedef unsigned int size_type;
      Foo(size_type n = size_type(0) ) { }
    };
  
  int foob(Foo<int> h = Foo<int>()) {return 1; }

  template <class T>
    struct Hello
    {
      typedef unsigned int size_type;

      // This works
      // Hello(size_type n = Hello<T>::size_type(0) ) { }

      // This doesn't
      Hello(size_type n = size_type(0) ) { }

      enum Hi { hi, hello };

      void foo(Hi h = hi) { }
    };

  template <typename T> struct X {
      X(const T& t = T()) {}
      X(double a, const T& t = T(0)) {}
      T meth(double a, const T& t = T(0)) { return t; }
      const T& meth(const T& t = T(0)) { return t; }
    };

  template <typename T> class Y : private X<T> {
  public:
    // test using on templated class with default args in the method
    using X<T>::meth;
  };

  template <int V> struct Z 
  {
    Z(int t = V) {}    
    // and also:
    Z(double a, int t = V){}
  };
  
  
%}

%template(Foo_int) Foo<int>;
%template(Hello_int) Hello<int>;
%template(X_int) X<int>;
%template(X_longlong) X<long long>;
%template(X_unsigned) X<unsigned>;
%template(Y_unsigned) Y<unsigned>;

%template(X_hello_unsigned) X<Hello<int> >;
%template(Y_hello_unsigned) Y<Hello<int> >;
%template(X_Foo_Foo_int) X<Foo<Foo<int> > >;
%template(Z_8) Z<8>;
%template(Foo_Z_8) Foo<Z<8> >;
%template(X_Foo_Z_8) X<Foo<Z<8> > >;

%inline %{

  struct Bar : Hello<int>
  {
    Bar(size_type n) : Hello<int>(n)
    {
    }
    
  };
%}


// Templated functions
%inline %{
  // Templated methods which are overloaded and have default args, and %template which
  // uses the same name as the C++ functions and overload on the template parameters and
  // specialization thrown in too. Wow, SWIG can handle this insane stuff!
  template<typename T, typename U> int ott(T t = 0, const U& u = U()) { return 10; }
  template<typename T, typename U> int ott(const char *msg, T t = 0, const U& u = U()) { return 20; }
  int ott(Foo<int>) { return 30; }
  template<typename T> int ott(Hello<int> h, T t = 0) { return 40; }
  template<> int ott<int>(Hello<int> h, int t) { return 50; }
  template<> int ott(Hello<int> h, double t) { return 60; }
%}

%template(ott) ott<int, int>;
%template(ott) ott<double>;
%template(ottint) ott<int>; // default arg requires a rename
%template(ottstring) ott<const char *>; // default arg requires a rename

