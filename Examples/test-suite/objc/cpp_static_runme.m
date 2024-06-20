#import "cpp_static_proxy.h"
#import<assert.h>

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
[StaticMemberTest setStatic_int:3];
assert([StaticMemberTest getStatic_int] ==3);
[StaticFunctionTest static_func_2:5];
[StaticFunctionTest static_func_3:5 param_2:10];
[pool drain];
return 0;
}
