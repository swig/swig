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
%}

%template(Hello_int) Hello<int>;

%inline %{

  struct hi : Hello<int>
  {
    hi(size_type n) : Hello<int>(n)
    {
    }
    
  };
%}



