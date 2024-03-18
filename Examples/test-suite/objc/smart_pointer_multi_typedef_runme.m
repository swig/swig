#import "smart_pointer_multi_typedef_proxy.h"
int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Foo *f=[[Foo alloc]init];
Bar *b =[[Bar alloc]initWithF:f];
Spam *s=[[Spam alloc]initWithB:b];
Grok *g=[[Grok alloc]initWithB:b];

[s setX:3];;
if([s getX] !=3)
NSLog(@"Runtime Error");

[g setX:4];
if([g getX] != 4)
NSLog(@"Runtime Error");

[f release];
[b release];
[s release];
[g release];

[pool drain];
 return 0;
}

