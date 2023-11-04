/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Fortran proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#include <string>
#include <exception>

namespace Swig {
  /* Base class for director exceptions */
  class DirectorException : public std::exception {
  protected:
    std::string swig_msg;

  public:
    explicit DirectorException(const char *msg) : swig_msg(msg) {
    }

    explicit DirectorException(const std::string &msg) : swig_msg(msg) {
    }

    virtual ~DirectorException() throw() {
    }

    const char *what() const throw() {
      return swig_msg.c_str();
    }
  };

  /* Pure virtual method exception */
  class DirectorPureVirtualException : public DirectorException {
  public:
    explicit DirectorPureVirtualException(const char *method_name) : DirectorException(std::string("Attempt to invoke pure virtual method ") + method_name) {
    }

    static void raise(const char *method_name) {
      throw DirectorPureVirtualException(method_name);
    }
  };
}

