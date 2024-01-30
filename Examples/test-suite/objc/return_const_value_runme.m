#import "return_const_value_proxy.h"

int main(int argc ,char *argv[])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
Foo_ptr  *ptr =[Foo_ptr  getPtr];
if ([ptr  getVal]  != 17)
NSLog(@"Runtime test1 failed");

ptr=[Foo_ptr getConstPtr];
if ([ptr getVal] != 17)
NSLog(@"Runtime test2 failed");

[pool drain];
return 0;
}