%module template_typedef_cplx5

%{
#include <complex>
%}


%inline %{

  // This typedef triggers an inifinite recursion
  // in the next test1() nd test2() function declarations

  typedef std::complex<double> complex;  

  struct A 
  {
    complex test1();
    std::complex<double> test2();
  };
  
%}

