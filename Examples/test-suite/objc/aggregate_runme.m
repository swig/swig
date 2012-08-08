#import "aggregate_proxy.h"

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
int result =ObjcMove(UP);
if(result!=UP)
NSLog(@"UP Failed");

result =ObjcMove(DOWN);
if(result!=DOWN)
NSLog(@"DOWN Failed");

result =ObjcMove(LEFT);
if(result!=LEFT)
NSLog(@"LEFT Failed");

result =ObjcMove(RIGHT);
if(result!=RIGHT)
NSLog(@"RIGHT Failed");

if(result ==ObjcMove(0))
NSLog(@"0 test failed");

[pool drain];
return 0;
}
