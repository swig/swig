/* -----------------------------------------------------------------------------
 * std_pair.i
 *
 * std::pair<T, U> wrapper support for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <utility>
%}

namespace std {

template<class T, class U> struct pair {
  typedef T first_type;
  typedef U second_type;

  pair();
  pair(T first, U second);
  pair(const pair &other);

  T first;
  U second;
};

}
