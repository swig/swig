#import "integers_proxy.h"
#import <assert.h>

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];

assert(ObjcSigned_char_identity(-3)   == -3);
assert(ObjcUnsigned_char_identity(5)  == 5);
assert(ObjcSigned_short_identity(-3)  == -3);
assert(ObjcUnsigned_short_identity(5) == 5);
assert(ObjcSigned_int_identity(-3)  == -3);
assert(ObjcUnsigned_int_identity(5) == 5);
assert(ObjcSigned_long_identity(-3)  == -3);
assert(ObjcUnsigned_long_identity(5) == 5);
assert(ObjcSigned_long_long_identity(-3)  == -3);
assert(ObjcUnsigned_long_long_identity(5) == 5);

[pool drain];
return 0;
}
