#import "aggregate_proxy.h"

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
int result =move(UP);
if(result!=UP)
NSLog(@"UP Failed");
result =move(DOWN);
if(result!=DOWN)
NSLog(@"DOWN Failed");
result =move(LEFT);
if(result!=UP)
NSLog(@"LEFT Failed");
result =move(RIGHT);
if(result!=bottom)
NSLog(@"RIGHT Failed");

if(result =move(0)
NSLog(@"0 test failed");

[pool drain];
return 0;
}
