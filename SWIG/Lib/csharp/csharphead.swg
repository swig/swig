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
  SWIG_CSharpException,
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

static SWIG_CSharpExceptions_t csharp_exceptions[] = {
  { SWIG_CSharpException, NULL },
  { SWIG_CSharpOutOfMemoryException, NULL },
  { SWIG_CSharpIndexOutOfRangeException, NULL },
  { SWIG_CSharpDivideByZeroException, NULL },
  { SWIG_CSharpArgumentOutOfRangeException, NULL },
  { SWIG_CSharpNullReferenceException, NULL } };

#if defined(SWIG_NOINCLUDE)
void SWIG_CSharpThrowException(SWIG_CSharpExceptionCodes code, const char *msg);
#else
void SWIG_CSharpThrowException(SWIG_CSharpExceptionCodes code, const char *msg) {
  SWIG_CSharpExceptionCallback_t callback = csharp_exceptions[SWIG_CSharpException].callback;
  if (code >=0 && code < sizeof(csharp_exceptions)/sizeof(SWIG_CSharpExceptionCodes)) {
    callback = csharp_exceptions[code].callback;
  }
  callback(msg);
}
#endif
%}

%{
#ifdef __cplusplus
extern "C" 
#endif
DllExport void SWIGSTDCALL SWIGRegisterExceptionCallbacks(SWIG_CSharpExceptionCallback_t systemException,
                                                          SWIG_CSharpExceptionCallback_t outOfMemory, 
                                                          SWIG_CSharpExceptionCallback_t indexOutOfRange, 
                                                          SWIG_CSharpExceptionCallback_t divideByZero, 
                                                          SWIG_CSharpExceptionCallback_t argumentOutOfRange,
                                                          SWIG_CSharpExceptionCallback_t nullReference) {
  csharp_exceptions[SWIG_CSharpException].callback = systemException;
  csharp_exceptions[SWIG_CSharpOutOfMemoryException].callback = outOfMemory;
  csharp_exceptions[SWIG_CSharpIndexOutOfRangeException].callback = indexOutOfRange;
  csharp_exceptions[SWIG_CSharpDivideByZeroException].callback = divideByZero;
  csharp_exceptions[SWIG_CSharpArgumentOutOfRangeException].callback = argumentOutOfRange;
  csharp_exceptions[SWIG_CSharpNullReferenceException].callback = nullReference;
}
%}

%pragma(csharp) imclasscode=%{
  public delegate void SWIGExceptionDelegate(string message);

  static SWIGExceptionDelegate systemDelegate = new SWIGExceptionDelegate(ThrowSystemException);
  static SWIGExceptionDelegate outOfMemoryDelegate = new SWIGExceptionDelegate(ThrowOutOfMemoryException);
  static SWIGExceptionDelegate indexOutOfRangeDelegate = new SWIGExceptionDelegate(ThrowIndexOutOfRangeException);
  static SWIGExceptionDelegate divideByZeroDelegate = new SWIGExceptionDelegate(ThrowDivideByZeroException);
  static SWIGExceptionDelegate argumentOutOfRangeDelegate = new SWIGExceptionDelegate(ThrowArgumentOutOfRangeException);
  static SWIGExceptionDelegate nullReferenceDelegate = new SWIGExceptionDelegate(ThrowNullReferenceException);

  [DllImport("$module", EntryPoint="SWIGRegisterExceptionCallbacks")]
  public static extern void SWIGRegisterExceptionCallbacks(
    SWIGExceptionDelegate systemExceptionDelegate,
    SWIGExceptionDelegate outOfMemoryDelegate, 
    SWIGExceptionDelegate indexOutOfRangeDelegate, 
    SWIGExceptionDelegate divideByZeroDelegate, 
    SWIGExceptionDelegate argumentOutOfRangeDelegate,
    SWIGExceptionDelegate nullReferenceDelegate);

  static void ThrowSystemException(string message) {
    throw new System.SystemException(message);
  }

  static void ThrowOutOfMemoryException(string message) {
    throw new System.OutOfMemoryException(message);
  }

  static void ThrowIndexOutOfRangeException(string message) {
    throw new System.IndexOutOfRangeException(message);
  }

  static void ThrowDivideByZeroException(string message) {
    throw new System.DivideByZeroException(message);
  }

  static void ThrowArgumentOutOfRangeException(string message) {
    throw new System.ArgumentOutOfRangeException(message);
  }

  static void ThrowNullReferenceException(string message) {
    throw new System.NullReferenceException(message);
  }

  static $modulePINVOKE() {
    SWIGRegisterExceptionCallbacks(systemDelegate, outOfMemoryDelegate, indexOutOfRangeDelegate, divideByZeroDelegate, argumentOutOfRangeDelegate, nullReferenceDelegate);
  }
%}
