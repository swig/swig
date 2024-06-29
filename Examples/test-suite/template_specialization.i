%module template_specialization

%rename(not1) *::operator!() const;
%rename(negate) *::operator-() const;

%warnfilter(SWIGWARN_PARSE_TEMPLATE_FORWARD) vfncs::OnlySpecialized<double>;

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
    
    // Also test specialization with only primary template forward declaration
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

  // Specialized instantiation with only primary template forward declaration
  %template(OnlySpecialized_int) OnlySpecialized<int>;

  // Primary instantiation with only primary template forward declaration
  %template(OnlySpecialized_double) OnlySpecialized<double>; // ignored with a warning
}

%{
namespace vfncs {
  template <typename T> struct OnlySpecialized {
    int primary() const { return 0; }
  };
}
%}

%inline %{
namespace vfncs {
  // Use primary template with only primary template forward declaration (for SWIG, but full declaration seen by compiler)
  OnlySpecialized<double> factory(OnlySpecialized<double>* os) {
    OnlySpecialized<double> ret = os ? *os : OnlySpecialized<double>();
    ret.primary();
    return ret;
  }
}
%}
