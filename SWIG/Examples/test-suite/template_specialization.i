%module template_specialization

%rename(__not__) *::operator!() const;

%inline %{
  
  namespace vfncs {
    
    template <class ArgType>
    struct UnaryFunction 
    {
      UnaryFunction operator-() const;
    };

    template <>
    struct UnaryFunction<bool>
    {
      // This works
      // UnaryFunction<bool> operator!() const;


      // This doesn't
      UnaryFunction operator!() const;
    };
    
  }
%}

namespace vfncs {  

  %template(UnaryFunction_double) UnaryFunction<double>;  
  %template(UnaryFunction_bool) UnaryFunction<bool>;  
}
