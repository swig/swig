#import "abstract_inherit_ok_proxy.h"
#import <assert.h>
int main(int argc,char *argv[])
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
 //Shouldn't be able to instantiate Foo,because it declares a pure virtual function 
	
	Spam *sp=[[Spam alloc] init];
	assert([sp blah] == 0);
	NSLog(@"Spam Object method");
	[sp release];
	[pool drain];
	
	return 0;
}