#import "constructor_value_proxy.h"
#import <assert.h>
int main(int argc,char *argv[ ])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
Foo *foo =[[Foo alloc]initWithA:5];
Bar *bar =[[Bar alloc]initWithCi:foo];
	assert( foo != bar);
NSLog(@"Test succeeds");
[foo release];
[bar release];
[pool drain];
return 0;
}