%module template_specialization_defarg

%inline %{

  template <class A, class B = double>
    struct C
    {
    };
  
  
  template <class BB>
    struct C<int , BB> 
    {
      int hi()
      {
	return 0;
      }

      C(int a)
      {
      }
      
    };
  

  template <class BB>
    struct C<double , BB> 
    {
      int hello()
      {
	return 0;
      }
      
      C(double a)
      {
      }
      
    };
  
      
%}


//
// This works fine
//
%template(C_i) C<int, double>;

//
// This one fails
//
%template(C_d) C<double>;
