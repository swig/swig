#import "struct_value_proxy.h"
#import<assert.h>
int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Bar *bar=[[Bar alloc]init];
[[bar getA]setX:3];
assert([[bar getA]getX] == 3);

[[bar getB]setX:3];
assert([[bar getB]getX] == 3);

[bar release];
[pool drain];
 return 0;
}
