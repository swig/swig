#import sneaky1_proxy

int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
if(add(30,2) !=32)
NSLog(@"add test failed");
if(subtract(20,2) !=18)
NSLog(@"subtract test failed");
if(mul(20,2) !=40)
NSLog("mul test failed");
if(divide(20,2) !=10)
NSLog(@"div test failed");

[pool drain];
return 0;
} 
