%module template_default_arg

%warnfilter(801) hi;	/* Ruby, wrong class name */

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

  template <typename T>
    struct X {
      X(T t = T());
      // and also:
      X(double a, T t = T(0));
    };

%}

%template(Hello_int) Hello<int>;
%template(X_int) X<int>;

%inline %{

  struct hi : Hello<int>
  {
    hi(size_type n) : Hello<int>(n)
    {
    }
    
  };
%}



