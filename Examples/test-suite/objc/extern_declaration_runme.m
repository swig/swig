#import "extern_declaration_proxy.h"
int main(int argc,char *argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
if(ObjcExternimport(100) !=100)
NSLog(@"extern import called");
if(ObjcExternexport(200) !=200)
NSLog(@"externexport failed");
if(ObjcExternstdcall(300) !=300)
NSLog(@"externstdcall failed");

[pool drain];
return 0;
}

