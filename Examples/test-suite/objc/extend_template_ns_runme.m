#import "extend_template_ns_proxy.h"
#import <assert.h>

int main(int argc,char *argv [ ])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
Foo_One *foo =[[Foo_One alloc]init];
assert([foo test1:37]  == 37);
assert([foo test2:42]  == 42 );

[foo release];
[pool drain];

return 0;
}