/* -----------------------------------------------------------------------------
 * objc.swg
 *
 * Objective-C runtime support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#import <Foundation/Foundation.h>
#include <stdlib.h>
#include <string.h>
%}

%insert(runtime) %{
/* Contract support */

#define SWIG_contract_assert(nullreturn, expr, msg) if (!(expr)) { /*throw exception*/ return nullreturn; } else
%}

%insert(runtime) %{
/* Support for throwing Objc exceptions */
typedef enum {
  SWIG_ObjcOutOfMemoryError = 1, 
  SWIG_ObjcIOException, 
  SWIG_ObjcRuntimeException, 
  SWIG_ObjcIndexOutOfBoundsException,
  SWIG_ObjcArithmeticException,
  SWIG_ObjcIllegalArgumentException,
  SWIG_ObjcNullPointerException,
  SWIG_ObjcDirectorPureVirtual,
  SWIG_ObjcUnknownError
} SWIG_ObjcExceptionCodes;

typedef struct {
  SWIG_ObjcExceptionCodes code;
  const char *Objc_exception;
} SWIG_ObjcExceptions_t;
%}

%insert(runtime) {
static void SWIGUNUSED SWIG_ObjcThrowException(SWIG_ObjcExceptionCodes code, const char *msg) {
  static const SWIG_ObjcExceptions_t Objc_exceptions[] = {
    { SWIG_ObjcOutOfMemoryError, "OutOfMemoryError" },
    { SWIG_ObjcIOException, "IOException" },
    { SWIG_ObjcRuntimeException, "RuntimeException" },
    { SWIG_ObjcIndexOutOfBoundsException, "IndexOutOfBoundsException" },
    { SWIG_ObjcArithmeticException, "ArithmeticException" },
    { SWIG_ObjcIllegalArgumentException, "IllegalArgumentException" },
    { SWIG_ObjcNullPointerException, "NullPointerException" },
    { SWIG_ObjcDirectorPureVirtual, "RuntimeException" },
    { SWIG_ObjcUnknownError,  "UnknownError" },
    { (SWIG_ObjcExceptionCodes)0,  "UnknownError" }
  };
  const SWIG_ObjcExceptions_t *except_ptr = Objc_exceptions;
  while (except_ptr->code != code && except_ptr->code)
   except_ptr++;
}
}


