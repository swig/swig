#import "template_tbase_template_proxy.h"
#import<assert.h>
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Funktion_dd *a=[[Funktion_dd alloc]init];
NSString *t = [a test];
assert([t isEqualToString:@"test"]);

[a release];

[pool drain];
return 0;
}

