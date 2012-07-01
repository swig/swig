#import "integers_proxy.h"
#import <assert.h>

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];

assert(signed_char_identity(-3)   == -3);
assert(unsigned_char_identity(5)  == 5);
assert(signed_short_identity(-3)  == -3);
assert(unsigned_short_identity(5) == 5);
assert(signed_int_identity(-3)  == -3);
assert(unsigned_int_identity(5) == 5);
assert(signed_long_identity(-3)  == -3);
assert(unsigned_long_identity(5) == 5);
assert(signed_long_long_identity(-3)  == -3);
assert(unsigned_long_long_identity(5) == 5);

[pool drain];
return 0;
}
