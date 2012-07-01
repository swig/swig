#import "typedef_reference_proxy.h"
#import<assert.h>

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
SWIGTYPE_p_int *int2=copy_intp(2);
assert(somefunc(int2) ==2);
SWIGTYPE_p_int *int3=copy_intp(3);
assert(somefunc(int3) ==3);
[pool drain];
return 0;
}

