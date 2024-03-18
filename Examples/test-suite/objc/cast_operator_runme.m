#import "cast_operator_proxy.h"
#import <assert.h>
int main(int argc,char *argv[])
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	A *a =[[A alloc]init];
	NSString *t=[a tochar];
	assert([t isEqualToString:@"hi"]);
	[a release];
	[pool drain];
	return 0;
}