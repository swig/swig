%module cpp11_shared_ptr_crtp_upcast

// Cutdown testcase for assert reported in https://github.com/swig/swig/issues/2768
// Note that this test has CRTP and %template instantiations for DiscretisedDensity template parameters not fully resolved

%warnfilter(SWIGWARN_JAVA_MULTIPLE_INHERITANCE,
	    SWIGWARN_CSHARP_MULTIPLE_INHERITANCE,
	    SWIGWARN_D_MULTIPLE_INHERITANCE,
	    SWIGWARN_RUBY_MULTIPLE_INHERITANCE,
	    SWIGWARN_PHP_MULTIPLE_INHERITANCE) stir::DiscretisedDensity<3,float>;

%include <std_shared_ptr.i>

%{
#include <memory>
namespace stir {}
using namespace stir;
%}

%inline %{
namespace stir {
  // Note: CRTP
  template <typename Derived, typename Base, typename Parent = Base>
  class RegisteredParsingObject : public Parent {
  };
}
%}

%shared_ptr(stir::Array<3,float>)
%inline %{
namespace stir {
  template <int num_dimensions, typename elemT>
  class Array {
  };
}
%}
%template(FloatArray3D) stir::Array<3,float>;

%shared_ptr(stir::ExamData);
%inline %{
namespace stir {
  class ExamData {
  };
}
%}

%shared_ptr(stir::DiscretisedDensity<3,float>)
%inline %{
namespace stir {
  template<int num_dimensions, typename elemT>
  class DiscretisedDensity : public ExamData, public Array<num_dimensions,elemT> {
  };
}
%}

%shared_ptr(stir::DataProcessor<stir::DiscretisedDensity<3,float> >)
%shared_ptr(stir::RegisteredParsingObject<
            stir::ChainedDataProcessor<stir::DiscretisedDensity<3,float> >,
            stir::DataProcessor<DiscretisedDensity<3,float> >,
	    stir::DataProcessor<DiscretisedDensity<3,float> > >)
%shared_ptr(stir::ChainedDataProcessor<stir::DiscretisedDensity<3,float> >)

%inline %{
namespace stir {
  template <typename DataT>
  class DataProcessor {
  };

  template <typename DataT>
  class ChainedDataProcessor : public RegisteredParsingObject< ChainedDataProcessor<DataT>, DataProcessor<DataT>, DataProcessor<DataT> > {
  };
}
%}

// SWIG will qualify Discretised in the %template() declaration even though Discretised
// is not in scope with the 'using namespace stir' below commented out.
//using namespace stir;
%template(Float3DDiscretisedDensity) stir::DiscretisedDensity<3,float>;
%template(DataProcessor3DFloat) stir::DataProcessor<stir::DiscretisedDensity<3,float> >;
%template(RPChainedDataProcessor3DFloat) stir::RegisteredParsingObject<
                                         stir::ChainedDataProcessor<stir::DiscretisedDensity<3,float> >,
                                         stir::DataProcessor<DiscretisedDensity<3,float> >,
                                         stir::DataProcessor<DiscretisedDensity<3,float> > >;
%template(ChainedDataProcessor3DFloat) stir::ChainedDataProcessor<stir::DiscretisedDensity<3,float> >;

%inline %{
void useobject(stir::RegisteredParsingObject<
               stir::ChainedDataProcessor<stir::DiscretisedDensity<3,float> >,
               stir::DataProcessor<DiscretisedDensity<3,float> >,
               stir::DataProcessor<DiscretisedDensity<3,float> > >) {
}
%}
