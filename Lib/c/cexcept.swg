/* -----------------------------------------------------------------------------
 * clabels.swg
 *
 * Exception handling code and typemaps for C module.
 * ----------------------------------------------------------------------------- */

// This function is special: it's used by various typemaps (via SWIG_exception
// macro below) and needs to be defined, but we don't want to export it.
%ignore SWIG_CException_Raise;
%{
extern "C" SWIGEXPORTC void SWIG_CException_Raise(int code, const char* msg);
%}

// This class is special too because its name is used in c.cxx source. It is
// only defined if the code there didn't predefine SWIG_CException_DEFINED
// because the class is already defined in another module.
//
// It has to be seen by SWIG because we want to generate wrappers for its
// public functions to be able to use it from the application code.
%inline %{
#ifndef SWIG_CException_DEFINED
class SWIG_CException {
public:
  SWIG_CException(const SWIG_CException& ex) throw() : code(ex.code), msg(strdup(ex.msg)) { }
  ~SWIG_CException() { free(const_cast<char*>(msg)); }

  const int code;
  const char* const msg;

  static SWIG_CException* get_pending() throw() {
    return PendingException;
  }

  static void reset_pending() throw() {
    if (PendingException) {
      delete PendingException;
      PendingException = 0;
    }
  }

private:
  friend void SWIG_CException_Raise(int code, const char* msg);

  static thread_local SWIG_CException* PendingException;

  SWIG_CException(int code, const char* msg) : code(code), msg(strdup(msg)) { }

  SWIG_CException& operator=(const SWIG_CException& ex);
};
#endif // SWIG_CException_DEFINED
%}

// This part is implementation only and doesn't need to be seen by SWIG.
%{
#ifndef SWIG_CException_DEFINED
thread_local SWIG_CException *SWIG_CException::PendingException = 0;

SWIGEXPORTC void SWIG_CException_Raise(int code, const char* msg) {
  delete SWIG_CException::PendingException;
  SWIG_CException::PendingException = new SWIG_CException(code, msg);
}
#endif // SWIG_CException_DEFINED
%}

#ifdef SWIG_CXX_WRAPPERS

// This is somewhat of a hack, but our generated header may include another
// generated header, when using multiple modules, and defining swig_check() in
// all of them would result in errors, so we use SWIG_swig_check_DEFINED to
// prevent this from happening.
//
// This also has a nice side effect of allowing the user code to predefine this
// symbol and provide their own SWIG_swig_check_DEFINED implementation to
// customize exception handling.
%insert("cxxcode") %{
#ifndef SWIG_swig_check_DEFINED
#define SWIG_swig_check_DEFINED 1

inline void swig_check() {
  if (SWIG_CException* swig_ex = SWIG_CException::get_pending()) {
    SWIG_CException swig_ex_copy{*swig_ex};
    delete swig_ex;
    SWIG_CException::reset_pending();
    throw swig_ex_copy;
  }
}

template <typename T> T swig_check(T x) {
  swig_check();
  return x;
}

#endif // SWIG_swig_check_DEFINED
%}

#endif // SWIG_CXX_WRAPPERS

%insert("runtime") "swigerrors.swg"

#define SWIG_exception(code, msg)\
  SWIG_CException_Raise(code, msg)

%typemap(throws, noblock="1") char *, const char * {
  SWIG_exception(SWIG_RuntimeError, $1);
}

%typemap(throws, noblock="1") SWIGTYPE {
  SWIG_exception(SWIG_UnknownError, "exception of type $1_type");
}
