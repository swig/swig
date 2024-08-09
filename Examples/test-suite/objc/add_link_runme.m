#import "add_link_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Foo *foo=[[Foo alloc]init];
foo =[foo blah];
[pool drain];
return 0;
}

