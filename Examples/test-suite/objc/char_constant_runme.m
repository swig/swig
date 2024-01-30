#import  "char_constant_proxy.h"
#import <assert.h>
int main(int argc,char *argv[ ])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	assert(CHAR_CONSTANT =='x');
	assert([STRING_CONSTANT isEqualToString:@"xyzzy"]);
	assert(ESC_CONST =='\1');
	assert(NULL_CONST =='\0');
	assert(SPECIALCHAR =='\341');
	
	[pool drain];
  return 0;

}
