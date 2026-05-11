#import <Foundation/Foundation.h>
#import "director_basic_proxy.h"

#include <assert.h>

@interface ObjcFoo : Foo
@end

@implementation ObjcFoo
-(NSString*)ping {
  return @"ObjcFoo::ping()";
}
@end

@interface ObjcMyClass : MyClass
@end

@implementation ObjcMyClass
-(Bar*)vmethod:(Bar*)b {
  [b setX:[b getX] + 100];
  return b;
}

-(Bar*)pmethod:(Bar*)b {
  [b setX:[b getX] + 200];
  return b;
}

-(int)nonOverride {
  return 999;
}
@end

int main(int argc, char *argv[]) {
  (void)argc;
  (void)argv;

  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  Foo *foo = [[Foo alloc] init];
  assert([[foo ping] isEqualToString:@"Foo::ping()"]);
  assert([[foo pong] isEqualToString:@"Foo::pong();Foo::ping()"]);

  ObjcFoo *objc_foo = [[ObjcFoo alloc] init];
  assert([[objc_foo ping] isEqualToString:@"ObjcFoo::ping()"]);
  assert([[objc_foo pong] isEqualToString:@"Foo::pong();ObjcFoo::ping()"]);

  ObjcMyClass *objc_class = [[ObjcMyClass alloc] initWithA:0];
  Bar *value_bar = [[Bar alloc] initWith_x:7];
  Bar *value_result = [objc_class cmethod:value_bar];
  assert([value_result getX] == 107);

  Bar *pointer_bar = [[Bar alloc] initWith_x:9];
  Bar *pointer_result = [MyClass call_pmethod:objc_class b:pointer_bar];
  assert([pointer_result getX] == 209);
  assert([pointer_bar getX] == 209);

  assert([MyClass call_nonOverride:objc_class] == 999);

  [pointer_bar release];
  [value_bar release];
  [objc_class release];
  [objc_foo release];
  [foo release];
  [pool release];

  return 0;
}
