%module template_forward

%{
namespace foo {
template<class T> class bar { };
}
%}

namespace foo {
   template<class T> class bar;
};

%inline %{
namespace foo {
   double test1(const bar<double> &x) { return 0; }
   bar<double> test2() {
	return bar<double>();
   }
}
%}



%inline {
  // Forward declarations
  template<class RangeScalar, class DomainScalar = RangeScalar> class LinearOpBase;
  template<class Scalar>  class VectorBase;  
}


%inline {
  // Class Describable
  class Describable {
  public:
  };
  
  // Class LinearOpBase
  template<class RangeScalar, class DomainScalar> 
    class LinearOpBase : virtual public Describable {
    public:
    }; // end class LinearOpBase<RangeScalar,DomainScalar>
  
  // Class VectorBase
  template<class Scalar>
    class VectorBase : virtual public LinearOpBase<Scalar>
    {
    public:
    }; // end class VectorBase<Scalar>
  
}


%template (LinearOpBase_double)    LinearOpBase<double>;
%template (VectorBase_double)      VectorBase<double>;
%template (LinearOpBase_int)    LinearOpBase<int,int>;
%template (VectorBase_int)      VectorBase<int>;

