#import "argout_proxy.h"
#import <assert.h>

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
int *int1=ObjcCopy_intp(42);
assert(ObjcIncp(int1) == 42);
assert(ObjcIntp_value(int1) ==43);

int *int2=ObjcCopy_intp(2);
assert(ObjcIncp(int2) == 2);
assert(ObjcIntp_value(int2) ==3);

int *int3=ObjcCopy_intp(7);
assert(ObjcIncp(int3) == 7);
assert(ObjcIntp_value(int3) ==8);

int *int4=ObjcCopy_intp(4);
assert(ObjcIncp(int4) == 4);
assert(ObjcIntp_value(int4) ==5);

[pool drain];
return 0;
}

