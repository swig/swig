/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Rust callbacks can be
 * called from C++.
 * ----------------------------------------------------------------------------- */

#include <exception>
#include <string>

#define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)

namespace Swig {
  class Director {
  protected:
    bool swig_disowned;

  public:
    Director() : swig_disowned(false) {
    }

    virtual ~Director() {
    }

    void swig_disown() {
      swig_disowned = true;
    }

    bool swig_is_disowned() const {
      return swig_disowned;
    }
  };

  class DirectorException : public std::exception {
  protected:
    std::string swig_msg;

  public:
    DirectorException(const char *msg) : swig_msg(msg) {
    }

    DirectorException(const std::string &msg) : swig_msg(msg) {
    }

    virtual ~DirectorException() SWIG_NOEXCEPT {
    }

    const char *what() const SWIG_NOEXCEPT {
      return swig_msg.c_str();
    }
  };

  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg) : DirectorException(std::string("Attempt to invoke pure virtual method ") + msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };

  class DirectorTypeMismatchException : public DirectorException {
  public:
    DirectorTypeMismatchException(const char *msg) : DirectorException(msg) {
    }

    static void raise(const char *msg) {
      throw DirectorTypeMismatchException(msg);
    }
  };
}
