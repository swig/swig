#import "typedef_class_proxy.h"
#import <assert.h>

int main(int argc ,char* argv [])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
RealA *a=[[RealA alloc]init];
[a setA:3];

B *b=[[B alloc]init];
[b testA:a];

[a release];
[b release];

[pool drain];
return 0;
}