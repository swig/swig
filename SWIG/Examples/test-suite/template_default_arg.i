%module template_default_arg

%warnfilter(801) hi;	/* Ruby, wrong class name */
%warnfilter(801) Hello;	/* Ruby, wrong class name */

%inline %{
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
      X(T t = T()) {}
      X(double a, T t = T(0)) {}
      T meth(double a, T t = T(0)) { return t; }
      T meth(T t = T(0)) { return t; }
    };
    template <typename T> class Y : private X<T> {
    public:
      // test using on templated class with default args in the method
      using X<T>::meth;
    };
%}

%template(Hello_int) Hello<int>;
%template(X_int) X<int>;
%template(X_longlong) X<long long>;
%template(X_unsigned) X<unsigned>;
%template(Y_unsigned) Y<unsigned>;

%template(X_hello_unsigned) X<Hello<int> >;
%template(Y_hello_unsigned) Y<Hello<int> >;

%inline %{

  struct hi : Hello<int>
  {
    hi(size_type n) : Hello<int>(n)
    {
    }
    
  };
%}



