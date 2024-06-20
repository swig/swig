#import "using_protected_proxy.h"
#import <assert.h>
int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
FooBar *f=[[FooBar alloc]init];
[f setX:3];
assert([f blah:4] == 4);

[f release];
[pool drain];

return 0;
}
