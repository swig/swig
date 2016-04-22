/* -----------------------------------------------------------------------------
 * clabels.swg
 *
 * Exception handling code and typemaps for C module.
 * ----------------------------------------------------------------------------- */

%ignore SWIG_CException::SWIG_CException;

%inline %{
class SWIG_CException {
public:
  SWIG_CException(int code, const char* msg) : code(code), msg(strdup(msg)) { }

  const int code;
  const char* const msg;

private:
  friend void SWIG_PendingException_reset();

  ~SWIG_CException() { free(const_cast<char*>(msg)); }

  SWIG_CException(const SWIG_CException& ex);
  SWIG_CException& operator=(const SWIG_CException& ex);
};

static SWIG_CException *SWIG_PendingException = 0;
inline SWIG_CException* SWIG_PendingException_get() { return SWIG_PendingException; }
inline void SWIG_PendingException_reset() {
  if (SWIG_PendingException) {
    delete SWIG_PendingException;
    SWIG_PendingException = 0;
  }
}
%}

%insert("runtime") "swigerrors.swg"

#define SWIG_exception(code, msg)\
  SWIG_PendingException = new SWIG_CException(code, msg)

%typemap(throws, noblock="1") char *, const char * {
  SWIG_exception(SWIG_RuntimeError, $1);
}

%typemap(throws, noblock="1") SWIGTYPE {
  SWIG_exception(SWIG_UnknownError, "exception of type $1_type");
}
