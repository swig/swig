#ifdef SWIGPYTHON
%module("templatereduce") template_typedef
#else
%module template_typedef
#endif
//
// Change this to #if 1 to test the 'test'
//
#if 0

#define real double
%{
#define real double
%}

#else

%inline %{
  typedef double real;
%}

#endif


%inline %{

  //  typedef double real;

  namespace vfncs {

    struct UnaryFunctionBase
    {
    };    
    
    template <class ArgType, class ResType>
    struct UnaryFunction;
    
    template <class ArgType, class ResType>
    struct ArithUnaryFunction;  
    
    template <class ArgType, class ResType>
    struct UnaryFunction : UnaryFunctionBase
    {
    };

    template <class ArgType, class ResType>
    struct ArithUnaryFunction : UnaryFunction<ArgType, ResType>
    {
    };      
    
    template <class ArgType, class ResType>         
    struct unary_func_traits 
    {
      typedef ArithUnaryFunction<ArgType, ResType > base;
    };
  
    template <class ArgType>
    inline
    typename unary_func_traits< ArgType, ArgType >::base
    make_Identity()
    {
      return typename unary_func_traits< ArgType, ArgType >::base();
    }

    template <class Arg1, class Arg2>
    struct arith_traits 
    {
    };

    template<>
    struct arith_traits< float, float >
    {
    
      typedef float argument_type;
      typedef float result_type;
      static const char* const arg_type;
      static const char* const res_type;
    };

    template<>
    struct arith_traits< real, real >
    {
    
      typedef real argument_type;
      typedef real result_type;
      static const char* const arg_type;
      static const char* const res_type;
    };

    template<>
    struct arith_traits< real, float >
    {
      typedef float argument_type;
      typedef real result_type;
      static const char* const arg_type;
      static const char* const res_type;
    };

    template<>
    struct arith_traits< float, real >
    {
      typedef float argument_type;
      typedef real result_type;
      static const char* const arg_type;
      static const char* const res_type;
    };

    template <class AF, class RF, class AG, class RG>
    inline
    ArithUnaryFunction<typename arith_traits< AF, AG >::argument_type,
		       typename arith_traits< RF, RG >::result_type >
    make_Multiplies(const ArithUnaryFunction<AF, RF>& f,
		    const ArithUnaryFunction<AG, RG >& g)
    {
      return 
	ArithUnaryFunction<typename arith_traits< AF, AG >::argument_type,
	                   typename arith_traits< RF, RG >::result_type>();
    }

#ifndef SWIG

    // Initialize these static class members

    const char* const arith_traits< float, float >::arg_type = "float";
    const char* const arith_traits< float, float >::res_type = "float";

    const char* const arith_traits< real, real >::arg_type = "real";
    const char* const arith_traits< real, real >::res_type = "real";

    const char* const arith_traits< real, float >::arg_type = "float";
    const char* const arith_traits< real, float >::res_type = "real";

    const char* const arith_traits< float, real >::arg_type = "float";
    const char* const arith_traits< float, real >::res_type = "real";

#endif

  }
%}

namespace vfncs {  
  %template(UnaryFunction_float_float) UnaryFunction<float, float >;  
  %template(ArithUnaryFunction_float_float) ArithUnaryFunction<float, float >;  
  %template() unary_func_traits<float, float >;
  %template() arith_traits<float, float >;
  %template(make_Identity_float) make_Identity<float >;

  %template(UnaryFunction_real_real) UnaryFunction<real, real >;  
  %template(ArithUnaryFunction_real_real) ArithUnaryFunction<real, real >;  

  %template() unary_func_traits<real, real >;
  %template() arith_traits<real, real >;
  %template(make_Identity_real) make_Identity<real >;

  /* [beazley] Added this part */
  %template() unary_func_traits<float,real>;
  %template(UnaryFunction_float_real) UnaryFunction<float,real>;
  %template(ArithUnaryFunction_float_real) ArithUnaryFunction<float,real>;

  /* */

  %template() arith_traits<real, float >;
  %template() arith_traits<float, real >;
  %template() arith_traits<float, float >;

  %template(make_Multiplies_float_float_real_real)
    make_Multiplies<float, float, real, real>;

  %template(make_Multiplies_float_float_float_float)
    make_Multiplies<float, float, float, float>;

  %template(make_Multiplies_real_real_real_real)
    make_Multiplies<real, real, real, real>;

}

#ifdef SWIGPYTHON
swig_type_info *SWIG_TypeQuery(const char* name);
#endif
