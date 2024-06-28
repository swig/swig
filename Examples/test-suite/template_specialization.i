%module template_specialization

%rename(not1) *::operator!() const;
%rename(negate) *::operator-() const;

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
    
    // Also test specialization without the primary template.
    template <typename T> struct OnlySpecialized;

    template <> struct OnlySpecialized<int>
    {
        void bar(const OnlySpecialized& other) { }
    };
  }
%}

namespace vfncs {
  %template(UnaryFunction_double) UnaryFunction<double>;  
  %template(UnaryFunction_bool) UnaryFunction<bool>;  

  %template(OnlySpecialized_int) OnlySpecialized<int>;
}
