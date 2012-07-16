#import "inherit_void_arg_proxy.h"
int main(int argc, char* argv[])
{
B *b=[[B alloc]init];
[b f];

[b release];
return 0;
}
