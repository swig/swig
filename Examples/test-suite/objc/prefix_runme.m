#import "prefix_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Foo *f=[[Foo alloc]init];
[f get_self];

[f release];
[pool drain];
return 0;
}
