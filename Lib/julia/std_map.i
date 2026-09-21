/* Map declarations for interfaces that supply their own conversion typemaps. */
%{
#include <map>
%}
namespace std {
  template <typename Key, typename T> class map {};
}
