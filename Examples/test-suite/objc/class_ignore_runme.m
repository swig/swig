#import "class_ignore_proxy.h"
#import<assert.h>
int main(int argc, char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Bar *bar =[[Bar alloc]init];
NSString *t= ObjcDo_blah(bar);
assert([t isEqualToString:@"Bar::blah"]);

[bar release];
[pool drain];

return 0;
}
