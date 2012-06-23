#import "extend_template_proxy.h"
#import <assert.h>

int main(int argc ,char * argv[ ])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
Foo_0 *foo =[[Foo_0 alloc]init];
assert([foo test1:37] == 37);
assert([foo test2:42] == 42);

[foo release];
[pool drain];

return 0;

}