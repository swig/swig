#import <Foundation/Foundation.h>
#import "director_simple_proxy.h"

#include <assert.h>

@interface ObjcIntDerived : IntBase
@end

@implementation ObjcIntDerived
-(id)init {
  return [super initWithI:0];
}

-(int)apply:(int)x {
  return x + 41;
}
@end

@interface ObjcBoolDerived : BoolBase
@end

@implementation ObjcBoolDerived
-(BOOL)apply:(BOOL)a b:(BOOL)b {
  return a == b;
}
@end

int main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  IntBase *base = [[IntBase alloc] initWithI:0];
  assert([base apply:5] == 10);
  assert(ObjcApply(base, 5) == 10);

  IntDerived *derived = [[IntDerived alloc] init];
  assert([derived apply:5] == 15);
  assert(ObjcApply(derived, 5) == 15);

  ObjcIntDerived *objc_derived = [[ObjcIntDerived alloc] init];
  assert([objc_derived apply:5] == 46);
  assert(ObjcApply(objc_derived, 5) == 46);

  BoolDerived *bool_derived = [[BoolDerived alloc] init];
  assert([bool_derived apply:YES b:NO] == YES);
  assert([bool_derived apply:YES b:YES] == NO);

  ObjcBoolDerived *objc_bool_derived = [[ObjcBoolDerived alloc] init];
  assert([objc_bool_derived apply:YES b:YES] == YES);
  assert([objc_bool_derived apply:YES b:NO] == NO);

  [objc_bool_derived release];
  [bool_derived release];
  [objc_derived release];
  [derived release];
  [base release];
  [pool release];

  return 0;
}
