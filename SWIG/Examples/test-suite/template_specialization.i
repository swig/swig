%module template_specialization

%rename(__not__) *::operator!() const;

#ifdef SWIGJAVA
%rename(negate) *::operator-() const;
#endif

%inline %{
  
  namespace vfncs {
    
    template <class ArgType>
    struct UnaryFunction 
    {
      UnaryFunction operator-() const { return *this; }
    };

    template <>
    struct UnaryFunction<bool>
    {
      // This works
      // UnaryFunction<bool> operator!() const;

      // This doesn't
      UnaryFunction operator!() const { return *this; }

      // Does this?
      void foo(UnaryFunction) { }
      
    };
    
  }
%}

namespace vfncs {  

  %template(UnaryFunction_double) UnaryFunction<double>;  
  %template(UnaryFunction_bool) UnaryFunction<bool>;  
}
