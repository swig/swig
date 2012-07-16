#import "clientdata_prop_a_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
A *a=new_tA();
test_tA(a);
test_A(a);

[pool drain];
return 0;
}
