#import "template_extend1_proxy.h"
#import <assert.h>
int main(int argc, char * argv[ ])
{
NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
lBaz *lb =[[lBaz alloc]init];
dBaz *db =[[dBaz alloc]init];

NSString *t =[lb foo];
assert([t  isEqualToString:@"lBaz::foo"]);

t=[db foo];
assert([t isEqualToString:@"dBaz::foo"]);

[lb release];
[db release];

[pool drain];
 return 0;
}