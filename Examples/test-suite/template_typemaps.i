%module template_typemap


%typemap(in) Integer1 
{
  /* do nothing */
}

%typemap(out) Integer1 
{
  /* do nothing */
}

%typemap(in) Integer2 
{
  /* do nothing */
}

%typemap(out) Integer2 
{
  /* do nothing */
}

%{
  typedef int Integer1;
%}


%inline %{
  typedef int Integer2;

  template <class T>
    struct Foo 
    {
      T val;
      
      T get_val() const 
      {
	return val;
      }

      void set_val(T v) 
      {
	val = v;
      }

#ifdef SWIG
       %typemap(in) Foo* "/* in typemap for Foo, with type T */" 
#endif
    };  
%}

%template(Foo_I1) Foo<Integer1>;
%template(Foo_I2) Foo<Integer2>;

%inline %{
  int bar(Foo<Integer1> *foo) {
    return 0;
  }  
%}

  
