#import "template_ref_type_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
XC *xc=[[XC alloc]init];
Y *y=[[Y alloc]init];
assert([y find:xc] == NO);

[xc release];
[y release];

[pool drain];
return 0;
}
