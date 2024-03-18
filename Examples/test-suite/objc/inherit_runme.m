#import  "inherit_proxy.h"
#import<Foundation/Foundation.h>
int main(int argc,char * argv[ ])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
CBase *cb =[[CBase alloc] init];
NSLog(@"The foo is %@",[cb Foo]);
[pool release];
return 0;
}

