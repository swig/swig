#import "disown_proxy.h"

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
A *a=[[A alloc]init];
B *b=[[B alloc]init];
[b acquire:a];

[a release];
[b release];
[pool drain];
return 0;
}

