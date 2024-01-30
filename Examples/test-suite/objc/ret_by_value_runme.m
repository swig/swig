#import "ret_by_value_proxy.h"

int main(int argc ,char *argv [ ])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
test *t =[[test alloc]init];
t=ObjcGet_test();
if([t getMyInt ] != 100)
NSLog(@"Runtime Test Failed");

if([t getMyShort ] != 200)
NSLog(@"Runtime Test Failed");

[pool drain];
return 0;
}
