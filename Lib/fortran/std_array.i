/* -------------------------------------------------------------------------
 * std_array.i
 * ------------------------------------------------------------------------- */

%{
#include <array>
%}

#warning "std::array support is not yet implemented"

namespace std {
template<class T, size_t N>
class array {
public:
};
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
