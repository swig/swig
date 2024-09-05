#import "voidtest_proxy.h"
int main (int argc,char *argv[ ])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Foo *foo=[[Foo alloc]init];
[foo memberfunc];
[Foo staticmemberfunc];//foo will result in error because staticmemeberfunc is a static member
void *v2 = ObjcVfunc2(foo);
Foo *v3	= ObjcVfunc3(v2);				
[foo release];
[pool drain];
return 0;
}
