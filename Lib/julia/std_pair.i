/* A pair can be instantiated as a proxy or returned as a Julia tuple. */
%{
#include <utility>
%}
namespace std {
  template <typename T1, typename T2> struct pair {
    T1 first;
    T2 second;
  };
}
