#import "operbool_proxy.h"
#import<assert.h>
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Test *test=[[Test alloc]init];
assert([test operator_bool] == NO);

[test release];
[pool drain];
 return 0;
}
