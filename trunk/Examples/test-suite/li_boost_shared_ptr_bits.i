%module li_boost_shared_ptr_bits

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

%include <boost_shared_ptr.i>
SWIG_SHARED_PTR(NonDynamic, NonDynamic)

#endif

#if defined(SWIGPYTHON)
%pythonnondynamic NonDynamic;
#endif

%inline %{
#include <boost/shared_ptr.hpp>
struct NonDynamic {
  int i;
};
boost::shared_ptr<NonDynamic> boing(boost::shared_ptr<NonDynamic> b) { return b; }
%}

