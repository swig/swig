#import "template_static_proxy.h"
int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
//Foo *foo=[[Foo alloc]init];
[Foo bar_double:1];
[pool drain];
return 0;
}
