%module template_typemap


%typemap(in) Integer 
{
  /* do nothing */
}

%typemap(out) Integer 
{
  /* do nothing */
}

%{
  typedef int Integer;
%}


%inline %{

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
    };  
%}

%template(Foo_i) Foo<int>;
%template(Foo_I) Foo<Integer>;



