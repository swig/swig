
#import "example_proxy.h"
@interface ObjCCallback: NSObjcet <OCCallback>
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

        OCCaller *caller=[[OCCaller alloc]init];
    ObjCCallback *callback=[[ObjCCallback alloc]init];
	[caller setCallback:callback];
	[caller call];
	[caller delCallback];
	
        NSLog(@"\n");
        NSLog(@"Adding and calling an ObjectiveC callback\n");
        NSLog(@"----------------------------------------\n");
    
	[caller release];
	[pool drain];

	return 0;
}
