#import  "abstract_access_proxy.h"
#import <assert.h>
int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	D  *d =  [[D alloc]init];
	assert([d do_x] == 1);
		
	[d release];
	[pool drain];
	return 0;
}