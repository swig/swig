/* -----------------------------------------------------------------------------
 * csharphead.swg
 *
 * CSharp support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#if defined(_WIN32) || defined(__CYGWIN32__)
#  define DllExport   __declspec( dllexport )
#  define SWIGSTDCALL __stdcall
#else
#  define DllExport  
#  define SWIGSTDCALL
#endif 
%}

%insert(runtime) %{
/* Support for throwing C# exceptions from C/C++. There are two types: 
 * Exceptions that take a message and ArgumentExceptions that take a message and a parameter name. */
typedef enum {
  SWIG_CSharpApplicationException,
  SWIG_CSharpArithmeticException,
  SWIG_CSharpDivideByZeroException,
  SWIG_CSharpIndexOutOfRangeException,
  SWIG_CSharpInvalidOperationException,
  SWIG_CSharpIOException,
  SWIG_CSharpNullReferenceException,
  SWIG_CSharpOutOfMemoryException,
  SWIG_CSharpOverflowException,
  SWIG_CSharpSystemException
} SWIG_CSharpExceptionCodes;

typedef enum {
  SWIG_CSharpArgumentException,
  SWIG_CSharpArgumentNullException,
  SWIG_CSharpArgumentOutOfRangeException,
} SWIG_CSharpExceptionArgumentCodes;

typedef void (SWIGSTDCALL* SWIG_CSharpExceptionCallback_t)(const char *);
typedef void (SWIGSTDCALL* SWIG_CSharpExceptionArgumentCallback_t)(const char *, const char *);

typedef struct {
  SWIG_CSharpExceptionCodes code;
  SWIG_CSharpExceptionCallback_t callback;
} SWIG_CSharpException_t;

typedef struct {
  SWIG_CSharpExceptionArgumentCodes code;
  SWIG_CSharpExceptionArgumentCallback_t callback;
} SWIG_CSharpExceptionArgument_t;

static SWIG_CSharpException_t SWIG_csharp_exceptions[] = {
  { SWIG_CSharpApplicationException, NULL },
  { SWIG_CSharpArithmeticException, NULL },
  { SWIG_CSharpDivideByZeroException, NULL },
  { SWIG_CSharpIndexOutOfRangeException, NULL },
  { SWIG_CSharpInvalidOperationException, NULL },
  { SWIG_CSharpIOException, NULL },
  { SWIG_CSharpNullReferenceException, NULL },
  { SWIG_CSharpOutOfMemoryException, NULL },
  { SWIG_CSharpOverflowException, NULL },
  { SWIG_CSharpSystemException, NULL }
};

static SWIG_CSharpExceptionArgument_t SWIG_csharp_exceptions_argument[] = {
  { SWIG_CSharpArgumentException, NULL },
  { SWIG_CSharpArgumentNullException, NULL },
  { SWIG_CSharpArgumentOutOfRangeException, NULL },
};

static void SWIG_CSharpSetPendingException(SWIG_CSharpExceptionCodes code, const char *msg) {
  SWIG_CSharpExceptionCallback_t callback = SWIG_csharp_exceptions[SWIG_CSharpApplicationException].callback;
  if (code >=0 && (size_t)code < sizeof(SWIG_csharp_exceptions)/sizeof(SWIG_CSharpException_t)) {
    callback = SWIG_csharp_exceptions[code].callback;
  }
  callback(msg);
}

static void SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpExceptionArgumentCodes code, const char *msg, const char *param_name) {
  SWIG_CSharpExceptionArgumentCallback_t callback = SWIG_csharp_exceptions_argument[SWIG_CSharpArgumentException].callback;
  if (code >=0 && (size_t)code < sizeof(SWIG_csharp_exceptions_argument)/sizeof(SWIG_CSharpExceptionArgument_t)) {
    callback = SWIG_csharp_exceptions_argument[code].callback;
  }
  callback(msg, param_name);
}
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C" 
#endif
DllExport void SWIGSTDCALL SWIGRegisterExceptionCallbacks_$module(
                                                SWIG_CSharpExceptionCallback_t application,
                                                SWIG_CSharpExceptionCallback_t arithmetic,
                                                SWIG_CSharpExceptionCallback_t divideByZero, 
                                                SWIG_CSharpExceptionCallback_t indexOutOfRange, 
                                                SWIG_CSharpExceptionCallback_t invalidOperation,
                                                SWIG_CSharpExceptionCallback_t io,
                                                SWIG_CSharpExceptionCallback_t nullReference,
                                                SWIG_CSharpExceptionCallback_t outOfMemory, 
                                                SWIG_CSharpExceptionCallback_t overflow, 
                                                SWIG_CSharpExceptionCallback_t system) {
  SWIG_csharp_exceptions[SWIG_CSharpApplicationException].callback = application;
  SWIG_csharp_exceptions[SWIG_CSharpArithmeticException].callback = arithmetic;
  SWIG_csharp_exceptions[SWIG_CSharpDivideByZeroException].callback = divideByZero;
  SWIG_csharp_exceptions[SWIG_CSharpIndexOutOfRangeException].callback = indexOutOfRange;
  SWIG_csharp_exceptions[SWIG_CSharpInvalidOperationException].callback = invalidOperation;
  SWIG_csharp_exceptions[SWIG_CSharpIOException].callback = io;
  SWIG_csharp_exceptions[SWIG_CSharpNullReferenceException].callback = nullReference;
  SWIG_csharp_exceptions[SWIG_CSharpOutOfMemoryException].callback = outOfMemory;
  SWIG_csharp_exceptions[SWIG_CSharpOverflowException].callback = overflow;
  SWIG_csharp_exceptions[SWIG_CSharpSystemException].callback = system;
}

#ifdef __cplusplus
extern "C" 
#endif
DllExport void SWIGSTDCALL SWIGRegisterExceptionArgumentCallbacks_$module(
                                                SWIG_CSharpExceptionArgumentCallback_t argument,
                                                SWIG_CSharpExceptionArgumentCallback_t argumentNull,
                                                SWIG_CSharpExceptionArgumentCallback_t argumentOutOfRange) {
  SWIG_csharp_exceptions_argument[SWIG_CSharpArgumentException].callback = argument;
  SWIG_csharp_exceptions_argument[SWIG_CSharpArgumentNullException].callback = argumentNull;
  SWIG_csharp_exceptions_argument[SWIG_CSharpArgumentOutOfRangeException].callback = argumentOutOfRange;
}
%}

%pragma(csharp) imclasscode=%{
  class SWIGExceptionHelper {

    public delegate void ExceptionDelegate(string message);
    public delegate void ExceptionArgumentDelegate(string message, string paramName);

    static ExceptionDelegate applicationDelegate = new ExceptionDelegate(ThrowApplicationException);
    static ExceptionDelegate arithmeticDelegate = new ExceptionDelegate(ThrowArithmeticException);
    static ExceptionDelegate divideByZeroDelegate = new ExceptionDelegate(ThrowDivideByZeroException);
    static ExceptionDelegate indexOutOfRangeDelegate = new ExceptionDelegate(ThrowIndexOutOfRangeException);
    static ExceptionDelegate invalidOperationDelegate = new ExceptionDelegate(ThrowInvalidOperationException);
    static ExceptionDelegate ioDelegate = new ExceptionDelegate(ThrowIOException);
    static ExceptionDelegate nullReferenceDelegate = new ExceptionDelegate(ThrowNullReferenceException);
    static ExceptionDelegate outOfMemoryDelegate = new ExceptionDelegate(ThrowOutOfMemoryException);
    static ExceptionDelegate overflowDelegate = new ExceptionDelegate(ThrowOverflowException);
    static ExceptionDelegate systemDelegate = new ExceptionDelegate(ThrowSystemException);

    static ExceptionArgumentDelegate argumentDelegate = new ExceptionArgumentDelegate(ThrowArgumentException);
    static ExceptionArgumentDelegate argumentNullDelegate = new ExceptionArgumentDelegate(ThrowArgumentNullException);
    static ExceptionArgumentDelegate argumentOutOfRangeDelegate = new ExceptionArgumentDelegate(ThrowArgumentOutOfRangeException);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterExceptionCallbacks_$module")]
    public static extern void SWIGRegisterExceptionCallbacks_$module(
                                ExceptionDelegate applicationDelegate,
                                ExceptionDelegate arithmeticDelegate,
                                ExceptionDelegate divideByZeroDelegate, 
                                ExceptionDelegate indexOutOfRangeDelegate, 
                                ExceptionDelegate invalidOperationDelegate,
                                ExceptionDelegate ioDelegate,
                                ExceptionDelegate nullReferenceDelegate,
                                ExceptionDelegate outOfMemoryDelegate, 
                                ExceptionDelegate overflowDelegate, 
                                ExceptionDelegate systemExceptionDelegate);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterExceptionArgumentCallbacks_$module")]
    public static extern void SWIGRegisterExceptionCallbacksArgument_$module(
                                ExceptionArgumentDelegate argumentDelegate,
                                ExceptionArgumentDelegate argumentNullDelegate,
                                ExceptionArgumentDelegate argumentOutOfRangeDelegate);

    static void ThrowApplicationException(string message) {
      SWIGPendingException.Set(new System.ApplicationException(message));
    }
    static void ThrowArithmeticException(string message) {
      SWIGPendingException.Set(new System.ArithmeticException(message));
    }
    static void ThrowDivideByZeroException(string message) {
      SWIGPendingException.Set(new System.DivideByZeroException(message));
    }
    static void ThrowIndexOutOfRangeException(string message) {
      SWIGPendingException.Set(new System.IndexOutOfRangeException(message));
    }
    static void ThrowInvalidOperationException(string message) {
      SWIGPendingException.Set(new System.InvalidOperationException(message));
    }
    static void ThrowIOException(string message) {
      SWIGPendingException.Set(new System.IO.IOException(message));
    }
    static void ThrowNullReferenceException(string message) {
      SWIGPendingException.Set(new System.NullReferenceException(message));
    }
    static void ThrowOutOfMemoryException(string message) {
      SWIGPendingException.Set(new System.OutOfMemoryException(message));
    }
    static void ThrowOverflowException(string message) {
      SWIGPendingException.Set(new System.OverflowException(message));
    }
    static void ThrowSystemException(string message) {
      SWIGPendingException.Set(new System.SystemException(message));
    }

    static void ThrowArgumentException(string message, string paramName) {
      SWIGPendingException.Set(new System.ArgumentException(message, paramName));
    }
    static void ThrowArgumentNullException(string message, string paramName) {
      SWIGPendingException.Set(new System.ArgumentNullException(paramName, message));
    }
    static void ThrowArgumentOutOfRangeException(string message, string paramName) {
      SWIGPendingException.Set(new System.ArgumentOutOfRangeException(paramName, message));
    }

    static SWIGExceptionHelper() {
      SWIGRegisterExceptionCallbacks_$module(
                                applicationDelegate,
                                arithmeticDelegate,
                                divideByZeroDelegate,
                                indexOutOfRangeDelegate,
                                invalidOperationDelegate,
                                ioDelegate,
                                nullReferenceDelegate,
                                outOfMemoryDelegate,
                                overflowDelegate,
                                systemDelegate);

      SWIGRegisterExceptionCallbacksArgument_$module(
                                argumentDelegate,
                                argumentNullDelegate,
                                argumentOutOfRangeDelegate);
    }
  }

  static SWIGExceptionHelper swigExceptionHelper = new SWIGExceptionHelper();

  public class SWIGPendingException {
    [ThreadStatic]
    private static Exception pendingException = null;
    private static int numExceptionsPending = 0;

    public static bool Pending {
      get {
        bool pending = false;
        if (numExceptionsPending > 0)
          if (pendingException != null)
            pending = true;
        return pending;
      } 
    }

    public static void Set(Exception e) {
      if (pendingException != null)
        throw new ApplicationException("FATAL: An earlier pending exception from unmanaged code was missed and thus not thrown (" + pendingException.ToString() + ")", e);
      pendingException = e;
      lock(typeof($modulePINVOKE)) {
        numExceptionsPending++;
      }
    }

    public static Exception Retrieve() {
      Exception e = null;
      if (numExceptionsPending > 0) {
        if (pendingException != null) {
          e = pendingException;
          pendingException = null;
          lock(typeof($modulePINVOKE)) {
            numExceptionsPending--;
          }
        }
      }
      return e;
    }
  }
%}

%insert(runtime) %{
/* Callback for returning strings to C# without leaking memory */
typedef char * (SWIGSTDCALL* SWIG_CSharpStringHelperCallback)(const char *);
static SWIG_CSharpStringHelperCallback SWIG_csharp_string_callback = NULL;
%}

%pragma(csharp) imclasscode=%{
  class SWIGStringHelper {

    public delegate string SWIGStringDelegate(string message);
    static SWIGStringDelegate stringDelegate = new SWIGStringDelegate(CreateString);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterStringCallback_$module")]
    public static extern void SWIGRegisterStringCallback_$module(SWIGStringDelegate stringDelegate);

    static string CreateString(string cString) {
      return cString;
    }

    static SWIGStringHelper() {
      SWIGRegisterStringCallback_$module(stringDelegate);
    }
  }

  static SWIGStringHelper swigStringHelper = new SWIGStringHelper();
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C" 
#endif
DllExport void SWIGSTDCALL SWIGRegisterStringCallback_$module(SWIG_CSharpStringHelperCallback callback) {
  SWIG_csharp_string_callback = callback;
}

/* Contract support */

#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) {SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentOutOfRangeException, msg, ""); return nullreturn; } else
%}
