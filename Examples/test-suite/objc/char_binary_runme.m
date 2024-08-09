#import "char_binary_proxy.h"
int main(int argc,char*argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Test *test=[[Test alloc]init];
NSString *t=@"hile";
NSString *t1=@"hil\0";

if([test strlen:t len:4] !=4)
NSLog(@"bad multi-arg typemap");

if([test strlen:t1 len:4] !=4)
NSLog(@"bad multi-arg typemap");

[pool drain];
return 0;
}
