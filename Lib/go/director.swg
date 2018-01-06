/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Go proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#include <exception>

namespace Swig {

  class DirectorException : public std::exception {
  };
}

