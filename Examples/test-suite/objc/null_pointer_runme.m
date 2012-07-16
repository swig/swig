#import "null_pointer_proxy.h"
#import<assert.h>
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
A *a=[[A alloc]init];
assert(func(a) == NO);
a=getnull();
assert(a == 0);

[a release];
[pool drain];
return 0;
}
 

