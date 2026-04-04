local v=require 'template_typedef_cplx2'

-- double case
local d = v.make_Identity_double()
assert(swig_type(d) == "vfncs::ArithUnaryFunction< vfncs::arith_traits< double,double >::argument_type,vfncs::arith_traits< double,double >::result_type > *|vfncs::unary_func_traits< double,double >::base *|vfncs::ArithUnaryFunction< double,double > *")
local e = v.make_Multiplies_double_double_double_double(d, d)
assert(swig_type(e) == "vfncs::ArithUnaryFunction< vfncs::arith_traits< double,double >::argument_type,vfncs::arith_traits< double,double >::result_type > *|vfncs::unary_func_traits< double,double >::base *|vfncs::ArithUnaryFunction< double,double > *")

-- complex case
local c = v.make_Identity_complex()
assert(swig_type(c) == "vfncs::ArithUnaryFunction< Complex,Complex > *|vfncs::ArithUnaryFunction< vfncs::arith_traits< std::complex< double >,std::complex< double > >::argument_type,vfncs::arith_traits< std::complex< double >,std::complex< double > >::result_type > *|vfncs::unary_func_traits< std::complex< double >,std::complex< double > >::base *|vfncs::ArithUnaryFunction< std::complex< double >,std::complex< double > > *")
local f = v.make_Multiplies_complex_complex_complex_complex(c, c)
assert(swig_type(f) == "vfncs::ArithUnaryFunction< Complex,Complex > *|vfncs::ArithUnaryFunction< vfncs::arith_traits< std::complex< double >,std::complex< double > >::argument_type,vfncs::arith_traits< std::complex< double >,std::complex< double > >::result_type > *|vfncs::unary_func_traits< std::complex< double >,std::complex< double > >::base *|vfncs::ArithUnaryFunction< std::complex< double >,std::complex< double > > *")

-- Mix case
local g = v.make_Multiplies_double_double_complex_complex(d, c)
assert(swig_type(g) == "vfncs::ArithUnaryFunction< double,Complex > *|vfncs::ArithUnaryFunction< vfncs::arith_traits< double,std::complex< double > >::argument_type,vfncs::arith_traits< double,std::complex< double > >::result_type > *|vfncs::ArithUnaryFunction< vfncs::arith_traits< std::complex< double >,double >::argument_type,vfncs::arith_traits< std::complex< double >,double >::result_type > *|vfncs::ArithUnaryFunction< double,std::complex< double > > *")

-- This should raise NoMethodError if it fails
assert(g:get_value() == 1)
local h = v.make_Multiplies_complex_complex_double_double(c, d)
assert(swig_type(h) == "vfncs::ArithUnaryFunction< double,Complex > *|vfncs::ArithUnaryFunction< vfncs::arith_traits< double,std::complex< double > >::argument_type,vfncs::arith_traits< double,std::complex< double > >::result_type > *|vfncs::ArithUnaryFunction< vfncs::arith_traits< std::complex< double >,double >::argument_type,vfncs::arith_traits< std::complex< double >,double >::result_type > *|vfncs::ArithUnaryFunction< double,std::complex< double > > *")
