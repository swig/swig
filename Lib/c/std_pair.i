%{
#include <utility>
%}

// Ideal, especially for the simple/primitive types, would be to represent
// pair<T,U> as a C struct with the 2 fields, but for now we use the simplest
// possible implementation, with the accessor functions required to work with
// the fields.

namespace std {
  template <class T, class U> struct pair {
    typedef T first_type;
    typedef U second_type;

    pair();
    pair(T first, U second);
    pair(const pair& other);

    template <class T2, class U2> pair(const pair<T2, U2> &other);

    T first;
    U second;
  };
}
