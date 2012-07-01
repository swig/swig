#import "argout_proxy.h"
#import <assert.h>

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
SWIGTYPE_p_int *int1=copy_intp(42);
assert(incp(int1) == 42);
assert(intp_value(int1) ==43);

SWIGTYPE_p_int *int2=copy_intp(2);
assert(incp(int2) == 2);
assert(intp_value(int2) ==3);

SWIGTYPE_p_int *int3=copy_intp(7);
assert(incp(int3) == 7);
assert(intp_value(int3) ==8);

SWIGTYPE_p_int *int4=copy_intp(4);
assert(incp(int4) == 4);
assert(intp_value(int4) ==5);

[pool drain];
return 0;
}

