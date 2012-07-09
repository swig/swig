#import "smart_pointer_typedef_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Foo *f=[[Foo alloc]init];
Bar *b=[[Bar alloc]initWithF:f];

[b setX:3];
assert([b getx] == 3);

Foo *fp= [b __deref__];
[fp setX:4];
assert([fp getx] == 4);

[f release];
[b release];

[pool drain];
return 0;
}
