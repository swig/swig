#import "sneaky1_proxy.h"

int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
if(ObjcAdd(30,2) !=32)
NSLog(@"add test failed");
if(ObjcSubtract(20,2) !=18)
NSLog(@"subtract test failed");
if(ObjcMul(20,2) !=40)
NSLog(@"mul test failed");
if(ObjcDivide(20,2) !=10)
NSLog(@"div test failed");

[pool drain];
return 0;
} 
