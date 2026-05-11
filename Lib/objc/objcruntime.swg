/* -----------------------------------------------------------------------------
 * objc.swg
 *
 * Objective-C runtime support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#import <objc/NSObject.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#ifdef nil
#undef nil
#endif
#ifdef Nil
#undef Nil
#endif

#ifndef SWIG_OBJC_RUNTIME_DECLARATIONS
#define SWIG_OBJC_RUNTIME_DECLARATIONS
typedef unsigned long NSUInteger;
typedef unsigned short unichar;
struct objc_object;
typedef struct objc_object *SWIGObjectiveCId;
typedef struct objc_class *Class;
typedef struct objc_selector *SEL;
typedef struct objc_method *Method;
typedef void (*IMP)(void);

#ifdef __cplusplus
extern "C" {
#endif
Class objc_getClass(const char *name);
Class object_getClass(SWIGObjectiveCId obj);
Method class_getInstanceMethod(Class cls, SEL name);
IMP method_getImplementation(Method m);
id objc_msgSend(id self, SEL op, ...);
#ifdef __cplusplus
}
#endif

@interface NSString : NSObject
+ (id)stringWithUTF8String:(const char *)bytes;
+ (id)stringWithCharacters:(const unichar *)characters length:(NSUInteger)length;
- (const char *)UTF8String;
- (NSUInteger)length;
- (unichar)characterAtIndex:(NSUInteger)index;
- (BOOL)isEqualToString:(NSString *)aString;
@end

@interface NSArray : NSObject
- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;
@end

@interface NSData : NSObject
+ (id)dataWithBytes:(const void *)bytes length:(NSUInteger)length;
- (const void *)bytes;
- (NSUInteger)length;
@end

@interface NSAutoreleasePool : NSObject
- (void)drain;
@end

@interface NSException : NSObject
+ (void)raise:(NSString *)name format:(NSString *)format, ...;
+ (id)exceptionWithName:(NSString *)name reason:(NSString *)reason userInfo:(id)userInfo;
@end

@protocol SWIGObjectiveCProxy
- (void *)getCptr;
- (id)initWithCptr:(void *)cptr swigOwnCObject:(BOOL)ownCObject;
@end

extern void NSLog(NSString *format, ...);
#endif

static id SWIG_ObjectiveC_NewProxy(const char *classname, void *cptr) {
  Class cls = classname ? objc_getClass(classname) : 0;
  if (!cptr || !cls)
    return 0;
  id proxy = [cls alloc];
  id initialized = [(id<SWIGObjectiveCProxy>)proxy initWithCptr:cptr swigOwnCObject:NO];
  return [initialized autorelease];
}
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

#define SWIG_exception(code, msg) SWIG_ObjcThrowException(code, msg)
#define SWIG_exception_fail(code, msg) do { SWIG_exception(code, msg); SWIG_fail; } while (0)
%}

%insert(runtime) {
static void SWIGUNUSED SWIG_ObjcThrowException(int code, const char *msg) {
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
  const char *type = except_ptr->Objc_exception;
  const char *reason = msg ? msg : "";
  NSException *exception = [NSException exceptionWithName:[NSString stringWithUTF8String:type]
                                                   reason:[NSString stringWithUTF8String:reason]
                                                 userInfo:0];
  @throw exception;
}

#ifdef __cplusplus
namespace Swig {
  class Director {
  public:
    virtual ~Director() {
    }
  };

  class DirectorException {
  public:
    DirectorException(const char *msg = "") : swig_msg(msg ? msg : "") {
    }
    virtual ~DirectorException() {
    }
    virtual const char *what() const {
      return swig_msg;
    }
    static void raise(const char *msg) {
      throw DirectorException(msg);
    }
  private:
    const char *swig_msg;
  };

  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg = "") : DirectorException(msg) {
    }
    static void raise(const char *msg) {
      SWIG_ObjcThrowException(SWIG_ObjcDirectorPureVirtual, msg);
    }
  };
}
#define SWIG_DIRECTOR_CAST(ARG) dynamic_cast<Swig::Director *>(ARG)
#endif
}
