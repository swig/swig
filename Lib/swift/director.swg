/* -----------------------------------------------------------------------------
 * director.swg
 *
 * Minimal Swig::Director infrastructure for Swift directors.
 *
 * lang.cxx emits upcall-detection code for every director-enabled class.
 * That code uses dynamic_cast<Swig::Director*> and
 * Swig::DirectorPureVirtualException::raise().  Swift director classes do NOT
 * inherit from Swig::Director (they inherit from the C++ base class directly),
 * so the upcall branch is dead code — but the types must exist to compile.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus

#include <string>
#include <exception>

namespace Swig {

class Director {
};

class DirectorException : public std::exception {
protected:
  std::string swig_msg;
public:
  DirectorException(const char *msg) : swig_msg(msg) {}
  DirectorException(const std::string &msg) : swig_msg(msg) {}
  virtual ~DirectorException() noexcept {}
  const char *what() const noexcept { return swig_msg.c_str(); }
};

class DirectorPureVirtualException : public DirectorException {
public:
  DirectorPureVirtualException(const char *msg)
      : DirectorException(std::string("Attempt to invoke pure virtual method ") + msg) {}
  [[noreturn]] static void raise(const char *msg) {
    throw DirectorPureVirtualException(msg);
  }
};

} // namespace Swig

#endif /* __cplusplus */
