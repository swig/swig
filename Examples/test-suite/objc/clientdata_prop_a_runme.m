#import "clientdata_prop_a_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
A *a=ObjcNew_tA();
ObjcTest_tA(a);
ObjcTest_A(a);

[pool drain];
return 0;
}
