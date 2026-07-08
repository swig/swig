%module rust_boost_shared_ptr

%include <boost_shared_ptr.i>

%{
#if defined(__has_include)
# if __has_include(<boost/shared_ptr.hpp>)
#include <boost/shared_ptr.hpp>
# else
#  include <memory>
namespace boost {
  using std::shared_ptr;
}
# endif
#else
# include <memory>
namespace boost {
  using std::shared_ptr;
}
#endif
%}

%inline %{
struct RustBoostSharedThing {
  RustBoostSharedThing() : value(0) {
  }
  RustBoostSharedThing(int value) : value(value) {
  }
  int value;
};
%}

%shared_ptr(RustBoostSharedThing)

%inline %{
boost::shared_ptr<RustBoostSharedThing> rust_make_boost_shared_thing(int value) {
  return boost::shared_ptr<RustBoostSharedThing>(new RustBoostSharedThing(value));
}

int rust_boost_shared_thing_value(boost::shared_ptr<RustBoostSharedThing> thing) {
  return thing ? thing->value : -1;
}
%}
