%module typemap_self

// This typemap should be ignored for self?
%typemap(in) A* (A* ptr) {
  if (SWIG_ConvertPtr($input, (void**) &ptr, $1_descriptor, 0) != -1) {
    $1 = ptr;
  } else  {
    $1 = new A();
  }
 }

// Simple but unsecure current fix
//%apply SWIGTYPE* {A* self}


%inline %{
  
  struct A
  {
    int foo() 
    {
      return 1;
    }
  };
  
  struct B
  {
    B(A*) 
    {
    }
  };
  
%}
