%module smart_pointer_protected

%inline %{

  namespace hi
  {    
    struct A 
    {
      virtual int value(A*) = 0;    
    };    
    
    struct B : A 
    {
    protected:
      int value(A*)
      {
	return 1;
      }
    };

    struct C
    {
      hi::B* operator->() const { return new hi::B(); }
    };
  }
  

%}

