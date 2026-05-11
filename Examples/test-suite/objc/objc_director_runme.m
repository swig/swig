#import <Foundation/Foundation.h>
#import "objc_director_proxy.h"

#include <assert.h>

@interface ObjCIntCallback : IntCallback
@end

@implementation ObjCIntCallback
-(int)run: (int)value {
  return value * 10;
}
@end

@interface ObjCBoolCallback : BoolCallback
@end

@implementation ObjCBoolCallback
-(BOOL)run: (BOOL)lhs rhs: (BOOL)rhs {
  return lhs && !rhs;
}
@end

int main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  IntCallback *base = [[IntCallback alloc] init];
  assert(ObjcCall_int_callback(base, 4) == 5);

  ObjCIntCallback *objc_int = [[ObjCIntCallback alloc] init];
  assert(ObjcCall_int_callback(objc_int, 4) == 40);

  ObjCBoolCallback *objc_bool = [[ObjCBoolCallback alloc] init];
  assert(ObjcCall_bool_callback(objc_bool, YES, NO) == YES);
  assert(ObjcCall_bool_callback(objc_bool, YES, YES) == NO);

  [objc_bool release];
  [objc_int release];
  [base release];
  [pool release];

  return 0;
}
