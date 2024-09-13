/* -----------------------------------------------------------------------------
 * dhead.swg
 *
 * Support code for function pointers. ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Contract support. */
#define SWIG_contract_assert(nullreturn, expr, msg) do { if (!(expr)) {SWIG_DSetPendingException(SWIG_DException, msg); return nullreturn; } } while (0)
%}


/*
 * Exception support code.
 */

%insert(runtime) %{
// Support for throwing D exceptions from C/C++.
typedef enum {
  SWIG_DException = 0,
  SWIG_DIllegalArgumentException,
  SWIG_DIllegalElementException,
  SWIG_DIOException,
  SWIG_DNoSuchElementException,
  SWIG_DNullReferenceException
} SWIG_DExceptionCodes;

typedef void (* SWIG_DExceptionCallback_t)(const char *);

typedef struct {
  SWIG_DExceptionCodes code;
  SWIG_DExceptionCallback_t callback;
} SWIG_DException_t;

static SWIG_DException_t SWIG_d_exceptions[] = {
  { SWIG_DException, NULL },
  { SWIG_DIllegalArgumentException, NULL },
  { SWIG_DIllegalElementException, NULL },
  { SWIG_DIOException, NULL },
  { SWIG_DNoSuchElementException, NULL },
  { SWIG_DNullReferenceException, NULL }
};

static void SWIGUNUSED SWIG_DSetPendingException(SWIG_DExceptionCodes code, const char *msg) {
  if ((size_t)code < sizeof(SWIG_d_exceptions)/sizeof(SWIG_DException_t)) {
    SWIG_d_exceptions[code].callback(msg);
  } else {
    SWIG_d_exceptions[SWIG_DException].callback(msg);
  }
}

#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT void SWIGRegisterExceptionCallbacks_$module(
  SWIG_DExceptionCallback_t exceptionCallback,
  SWIG_DExceptionCallback_t illegalArgumentCallback,
  SWIG_DExceptionCallback_t illegalElementCallback,
  SWIG_DExceptionCallback_t ioCallback,
  SWIG_DExceptionCallback_t noSuchElementCallback,
  SWIG_DExceptionCallback_t nullReferenceCallback) {
  SWIG_d_exceptions[SWIG_DException].callback = exceptionCallback;
  SWIG_d_exceptions[SWIG_DIllegalArgumentException].callback = illegalArgumentCallback;
  SWIG_d_exceptions[SWIG_DIllegalElementException].callback = illegalElementCallback;
  SWIG_d_exceptions[SWIG_DIOException].callback = ioCallback;
  SWIG_d_exceptions[SWIG_DNoSuchElementException].callback = noSuchElementCallback;
  SWIG_d_exceptions[SWIG_DNullReferenceException].callback = nullReferenceCallback;
}
%}

%pragma(d) imdmoduleimports=%{
static import std.conv;
%}

%pragma(d) imdmodulecode=%{
private class SwigExceptionHelper {
  static this() {
	// The D1/Tango version maps C++ exceptions to multiple exception types.
    swigRegisterExceptionCallbacks$module(
      &setException,
      &setException,
      &setException,
      &setException,
      &setException,
      &setException
    );
  }

  static void setException(const char* message) {
    auto exception = new object.Exception(std.conv.to!string(message));
    SwigPendingException.set(exception);
  }
}

public class SwigPendingException {
public:
  static this() {
    m_sPendingException = null;
  }

  static bool isPending() {
    return m_sPendingException !is null;
  }

  static void set(object.Exception e) {
    if (m_sPendingException !is null) {
      e.next = m_sPendingException;
      throw new object.Exception("FATAL: An earlier pending exception from C/C++ code " ~
        "was missed and thus not thrown (" ~ m_sPendingException.classinfo.name ~
        ": " ~ m_sPendingException.msg ~ ")!", e);
    }

    m_sPendingException = e;
  }

  static object.Exception retrieve() {
    auto e = m_sPendingException;
    m_sPendingException = null;
    return e;
  }

private:
  // The reference to the pending exception (if any) is stored thread-local.
  static object.Exception m_sPendingException;
}
alias void function(const char* message) SwigExceptionCallback;
%}
// Callback registering function in wrapperloader.swg.


/*
 * String support code.
 */

%insert(runtime) %{
// Callback for returning strings to D without leaking memory.
typedef char * (* SWIG_DStringHelperCallback)(const char *);
static SWIG_DStringHelperCallback SWIG_d_string_callback = NULL;

#ifdef __cplusplus
extern "C"
#endif
SWIGEXPORT void SWIGRegisterStringCallback_$module(SWIG_DStringHelperCallback callback) {
  SWIG_d_string_callback = callback;
}
%}

%pragma(d) imdmoduleimports = %{
static import std.conv;
static import std.string;
%}

%pragma(d) imdmodulecode = %{
private class SwigStringHelper {
  static this() {
    swigRegisterStringCallback$module(&createString);
  }

  static const(char)* createString(const(char*) cString) {
    // We are effectively dup'ing the string here.
    // TODO: Is this correct for D2/Phobos?
    return std.string.toStringz(std.conv.to!string(cString));
  }
}
alias const(char)* function(const(char*) cString) SwigStringCallback;
%}
// Callback registering function in wrapperloader.swg.


/*
 * Function pointer support code.
 */
%pragma(d) imdmodulecode = %{
template SwigExternC(T) if (is(typeof(*(T.init)) P == function)) {
  static if (is(typeof(*(T.init)) R == return)) {
    static if (is(typeof(*(T.init)) P == function)) {
      alias extern(C) R function(P) SwigExternC;
    }
  }
}
%}
