
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	
	
	NSLog(@"ICONST  = %i (should be 42)\n", ICONST);
	NSLog(@"FCONST  = %f (should be 2.1828)\n", FCONST);
	NSLog(@"CCONST  = %c (should be 'x')\n", CCONST);
	NSLog(@"CCONST2 = %c (this should be on a new line)\n", CCONST2);
	NSLog(@"SCONST  = %@ (should be 'Hello World')\n", SCONST);
	NSLog(@"SCONST2 = %@ (should be '\"Hello World\"')\n", SCONST2);
	NSLog(@"EXPR    = %f (should be 48.5484)\n", EXPR);
	NSLog(@"iconst  = %i (should be 37)\n", iconst);
	NSLog(@"fconst  = %f (should be 3.14)\n",fconst);
	return 0;
	
}
