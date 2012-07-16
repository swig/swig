#import "sym_proxy.h"
int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
Flim *flim=[[Flim alloc]init];
NSString *str=[flim Jar];
assert([str isEqualToString:@"flim-jar"]);
Flam *flam=[[Flam alloc]init];

str=[flam Jar];
assert([str isEqualToString:@"flam-jar"]);
[flim release];
[flam release];
[pool drain];

return 0;
}

