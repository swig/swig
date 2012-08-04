
#import "example_proxy.h"
@interface ObjCCallback: Callback
- (id)init;
- (void)run;
@end

@implementation ObjCCallback
- (id)init {
    self = [super init];
    return self;
}
- (void)run {
    NSLog(@"ObjCCallback run()");
}
@end
int main(int argc, char* argv[]) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Adding and calling a normal C++ callback\n");
        NSLog(@"----------------------------------------\n");

        Caller *caller=[[Caller alloc]init];
	Callback *callback=[[Callback alloc]init];
	[caller Caller_setCallback:callback];
	[caller Caller_call];
	[caller Caller_delCallback];
	
        NSLog(@"\n");
        NSLog(@"Adding and calling an ObjectiveC callback\n");
        NSLog(@"----------------------------------------\n");
    
	Callback *objcallback=[[ObjCCallback alloc] init];
	[caller Caller_setCallback:objcallback];
	[caller Caller_call];
	[caller Caller_delCallback];
	
	[caller release];
	[pool drain];

	return 0;
}
