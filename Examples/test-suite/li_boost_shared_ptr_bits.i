%module li_boost_shared_ptr_bits

%include <boost_shared_ptr.i>

#if defined(SWIGPYTHON)
%pythonnondynamic NonDynamic;
#endif

SWIG_SHARED_PTR(NonDynamic, NonDynamic)

%inline %{
#include <boost/shared_ptr.hpp>
struct NonDynamic {
  int i;
};
boost::shared_ptr<NonDynamic> boing(boost::shared_ptr<NonDynamic> b) { return b; }
%}

