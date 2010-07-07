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


/////////////////////////////////////////////////
// Test non public destructor - was leading to memory leaks as the destructor was not wrapped
// Bug 3024875
/////////////////////////////////////////////////

%shared_ptr(HiddenDestructor)

%inline %{
class HiddenDestructor;
typedef boost::shared_ptr< HiddenDestructor > FooPtr;

class HiddenDestructor {
public:
   static FooPtr create();
   virtual void doit();

protected:
   HiddenDestructor();
   static void Foo_body( FooPtr self );
   virtual ~HiddenDestructor();
private:
   HiddenDestructor( const HiddenDestructor& );
   class Impl;
   Impl* impl_;

   class FooDeleter {
   public:
     void operator()(HiddenDestructor* hidden) {
       delete hidden;
     }
   };
};
%}

%{
#include <iostream>
using namespace std;

/* Impl would generally hold a weak_ptr to HiddenDestructor a.s.o, but this stripped down example should suffice */
class HiddenDestructor::Impl {
public:
    int mymember;
};

FooPtr HiddenDestructor::create()
{
    FooPtr hidden( new HiddenDestructor(), HiddenDestructor::FooDeleter() );
    Foo_body( hidden );
    return hidden;
}

void HiddenDestructor::doit()
{
    // whatever
}

HiddenDestructor::HiddenDestructor()
{
//  cout << "HiddenDestructor::HiddenDestructor()" << endl;
    // always empty
}

void HiddenDestructor::Foo_body( FooPtr self )
{
    // init self as you would do in ctor
    self->impl_ = new Impl();
}

HiddenDestructor::~HiddenDestructor()
{
//  cout << "HiddenDestructor::~HiddenDestructor()" << endl;
    // destruct (e.g. delete Pimpl object)
    delete impl_;
}
%}
////////////////////////////

