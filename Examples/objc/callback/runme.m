
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	Caller *caller=[[Caller alloc]init];
	Callback *callback=[[Callback alloc]init];
	[caller setCallback:callback];
	[caller call];
	[caller delCallback];
		
	[callback release];
	[pool drain];

	return 0;
}
