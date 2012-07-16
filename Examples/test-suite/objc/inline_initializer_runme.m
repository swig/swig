#import "inline_initializer_proxy.h"
int main(int argc,char* argv[])
{
Foo *foo=[[Foo alloc]initWithA:5];
[foo release];
return 0;
}
