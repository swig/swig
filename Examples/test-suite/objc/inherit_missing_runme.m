#import "inherit_missing_proxy.h"
#import<assert.h>
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
SWIGTYPE_p_Foo *a=new_Foo();
Bar *b=[[Bar alloc]init];
Spam *c=[[Spam alloc]init];
NSString *t=do_blah(a);
assert([t isEqualToString:@"Foo::blah"]);

t=[b blah];
assert([t isEqualToString:@"Bar::blah"]);

t=[c blah];
assert([t isEqualToString:@"Spam::blah"]);

[b release];
[c release];

[pool drain];
return 0;
}
