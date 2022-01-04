/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * std_except.i
 *
 * Typemaps used by the STL wrappers that throw exceptions.
 * These typemaps are used when methods are declared with an STL exception specification, such as
 *   size_t at() const throw (std::out_of_range);
 * ----------------------------------------------------------------------------- */

%{
#include <stdexcept>
%}

namespace std 
{
  %ignore exception;
  struct exception {};
}
