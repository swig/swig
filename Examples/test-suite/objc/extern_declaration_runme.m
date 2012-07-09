#import "extern_declaration_proxy.h"
int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
if(externimport(100) !=100)
NSLog(@"extern import called");
if(externexport(200) !=200)
NSLog(@"externexport failed");
if(externstdcall(300) !=300)
NSLog(@"externstdcall failed");

[pool drain];
return 0;
}

