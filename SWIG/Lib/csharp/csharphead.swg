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
/* Support for throwing C# exceptions from C/C++ */
typedef enum {
  SWIG_CSharpSystemException,
  SWIG_CSharpOutOfMemoryException,
  SWIG_CSharpIndexOutOfRangeException,
  SWIG_CSharpDivideByZeroException,
  SWIG_CSharpArgumentOutOfRangeException,
  SWIG_CSharpNullReferenceException
} SWIG_CSharpExceptionCodes;

typedef void (SWIGSTDCALL* SWIG_CSharpExceptionCallback_t)(const char *);

typedef struct {
  SWIG_CSharpExceptionCodes code;
  SWIG_CSharpExceptionCallback_t callback;
} SWIG_CSharpExceptions_t;

static SWIG_CSharpExceptions_t SWIG_csharp_exceptions[] = {
  { SWIG_CSharpSystemException, NULL },
  { SWIG_CSharpOutOfMemoryException, NULL },
  { SWIG_CSharpIndexOutOfRangeException, NULL },
  { SWIG_CSharpDivideByZeroException, NULL },
  { SWIG_CSharpArgumentOutOfRangeException, NULL },
  { SWIG_CSharpNullReferenceException, NULL } };

static void SWIG_CSharpSetPendingException(SWIG_CSharpExceptionCodes code, const char *msg) {
  SWIG_CSharpExceptionCallback_t callback = SWIG_csharp_exceptions[SWIG_CSharpSystemException].callback;
  if (code >=0 && (size_t)code < sizeof(SWIG_csharp_exceptions)/sizeof(SWIG_CSharpExceptions_t)) {
    callback = SWIG_csharp_exceptions[code].callback;
  }
  callback(msg);
}
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C" 
#endif
DllExport void SWIGSTDCALL SWIGRegisterExceptionCallbacks_$module(SWIG_CSharpExceptionCallback_t systemException,
                                                          SWIG_CSharpExceptionCallback_t outOfMemory, 
                                                          SWIG_CSharpExceptionCallback_t indexOutOfRange, 
                                                          SWIG_CSharpExceptionCallback_t divideByZero, 
                                                          SWIG_CSharpExceptionCallback_t argumentOutOfRange,
                                                          SWIG_CSharpExceptionCallback_t nullReference) {
  SWIG_csharp_exceptions[SWIG_CSharpSystemException].callback = systemException;
  SWIG_csharp_exceptions[SWIG_CSharpOutOfMemoryException].callback = outOfMemory;
  SWIG_csharp_exceptions[SWIG_CSharpIndexOutOfRangeException].callback = indexOutOfRange;
  SWIG_csharp_exceptions[SWIG_CSharpDivideByZeroException].callback = divideByZero;
  SWIG_csharp_exceptions[SWIG_CSharpArgumentOutOfRangeException].callback = argumentOutOfRange;
  SWIG_csharp_exceptions[SWIG_CSharpNullReferenceException].callback = nullReference;
}
%}

%pragma(csharp) imclasscode=%{
  class SWIGExceptionHelper {

    public delegate void ExceptionDelegate(string message);

    static ExceptionDelegate systemDelegate = new ExceptionDelegate(ThrowSystemException);
    static ExceptionDelegate outOfMemoryDelegate = new ExceptionDelegate(ThrowOutOfMemoryException);
    static ExceptionDelegate indexOutOfRangeDelegate = new ExceptionDelegate(ThrowIndexOutOfRangeException);
    static ExceptionDelegate divideByZeroDelegate = new ExceptionDelegate(ThrowDivideByZeroException);
    static ExceptionDelegate argumentOutOfRangeDelegate = new ExceptionDelegate(ThrowArgumentOutOfRangeException);
    static ExceptionDelegate nullReferenceDelegate = new ExceptionDelegate(ThrowNullReferenceException);

    [DllImport("$dllimport", EntryPoint="SWIGRegisterExceptionCallbacks_$module")]
    public static extern void SWIGRegisterExceptionCallbacks_$module(
      ExceptionDelegate systemExceptionDelegate,
      ExceptionDelegate outOfMemoryDelegate, 
      ExceptionDelegate indexOutOfRangeDelegate, 
      ExceptionDelegate divideByZeroDelegate, 
      ExceptionDelegate argumentOutOfRangeDelegate,
      ExceptionDelegate nullReferenceDelegate);

    static void ThrowSystemException(string message) {
      SWIGPendingException.Set(new System.SystemException(message));
    }

    static void ThrowOutOfMemoryException(string message) {
      SWIGPendingException.Set(new System.OutOfMemoryException(message));
    }

    static void ThrowIndexOutOfRangeException(string message) {
      SWIGPendingException.Set(new System.IndexOutOfRangeException(message));
    }

    static void ThrowDivideByZeroException(string message) {
      SWIGPendingException.Set(new System.DivideByZeroException(message));
    }

    static void ThrowArgumentOutOfRangeException(string message) {
      SWIGPendingException.Set(new System.ArgumentOutOfRangeException(message));
    }

    static void ThrowNullReferenceException(string message) {
      SWIGPendingException.Set(new System.NullReferenceException(message));
    }

    static SWIGExceptionHelper() {
      SWIGRegisterExceptionCallbacks_$module(systemDelegate, outOfMemoryDelegate, indexOutOfRangeDelegate, divideByZeroDelegate, argumentOutOfRangeDelegate, nullReferenceDelegate);
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
      if (pendingException != null) // Checks for missing pending exception code
        throw new Exception("FATAL: An earlier pending exception from unmanaged code was missed and thus not thrown (" + pendingException.ToString() + ")", e); // unmanaged code destructors may not be called
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

#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) {SWIG_CSharpSetPendingException(SWIG_CSharpArgumentOutOfRangeException, msg); return nullreturn; } else
%}
