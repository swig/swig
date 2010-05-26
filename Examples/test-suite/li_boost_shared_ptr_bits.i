%module li_boost_shared_ptr_bits

#if defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

%include <boost_shared_ptr.i>
%shared_ptr(NonDynamic)

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

// vector of shared_ptr
%include "std_vector.i"

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)

%shared_ptr(IntHolder);

#endif

%inline %{
#include "boost/shared_ptr.hpp"
struct IntHolder {
  int val;
  IntHolder(int a) : val(a) {}
};
int sum(std::vector< boost::shared_ptr<IntHolder> > v) {
  int sum = 0;
  for (size_t i=0; i<v.size(); ++i)
    sum += v[i]->val;
  return sum;
}
%}

%template(VectorIntHolder) std::vector< boost::shared_ptr<IntHolder> >;

