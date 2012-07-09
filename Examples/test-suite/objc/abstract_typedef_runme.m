#import "abstract_typedef_proxy.h"
#import <assert.h>
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Engine *e=[[Engine alloc]init];
A *a=[[A alloc]init];
assert([a write:e] == YES);

[e release];
[a release];

[pool drain];
return 0;
}
