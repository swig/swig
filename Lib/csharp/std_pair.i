//
// SWIG typemaps for std::pair
// Luigi Ballabio
// July 2003
//
// Common implementation

%include <std_common.i>
%include <exception.i>

// ------------------------------------------------------------------------
// std::pair
// ------------------------------------------------------------------------

%{
#include <utility>
%}

namespace std {

  template<class T, class U> struct pair {

    pair();
    pair(T t, U u);
    pair(const pair& p);

    template <class U1, class U2> pair(const pair<U1, U2> &p);

    T first;
    U second;
  };

  // add specializations here

}
