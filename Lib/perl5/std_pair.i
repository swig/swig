//
// SWIG typemaps for std::pair
// Luigi Ballabio
// July 2003
//
// Common implementation

%include std_common.i
%include exception.i

// ------------------------------------------------------------------------
// std::pair
// ------------------------------------------------------------------------

%{
#include <utility>
%}

// exported class

namespace std {

    template<class T, class U> struct pair {
        // add typemaps here
        T first;
        U second;
    };

    // add specializations here

}
