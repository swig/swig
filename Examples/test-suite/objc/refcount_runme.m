#import "refcount_proxy.h"

int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
A *a=[[A alloc]init];
B *b1=[[B alloc]initWithA:a];
B *b2=[[B alloc]initWithA:a];
 if([a ref_count] ==3)
NSLog(@"This program will crash....now\n");
[a release];
[b1 release];
[b2 release];
[pool drain];
return 0;
}
