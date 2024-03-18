#import "casts_proxy.h"
#import <assert.h>

int main(int argc,char *argv[])
{
NSAutoreleasePool  *pool=[[NSAutoreleasePool alloc]init];
A *a=[[A alloc]init];
B *b =[[B alloc]init];
[a hello];
[b hello];
assert([b isKindOfClass:[A class]] == true);

[a release];
[b release];
[pool drain];
return 0;
}