/* -------------------------------------------------------------------------
 * std_map.i
 * ------------------------------------------------------------------------- */

%{
#include <map>
  %}
#warning "std::map support is not yet implemented"

namespace std {

template<class K, class T>
class map {};
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
