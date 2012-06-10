
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	
	
	printf("ICONST  = %i (should be 42)\n", ICONST);
	printf("FCONST  = %f (should be 2.1828)\n", FCONST);
	printf("CCONST  = %c (should be 'x')\n", CCONST);
	printf("CCONST2 = %c (this should be on a new line)\n", CCONST2);
	printf("SCONST  = %s (should be 'Hello World')\n", SCONST);
	printf("SCONST2 = %s (should be '\"Hello World\"')\n", SCONST2);
	printf("EXPR    = %f (should be 48.5484)\n", EXPR);
	printf("iconst  = %i (should be 37)\n", iconst);
	printf("fconst  = %f (should be 3.14)\n",fconst);
	return 0;
	
}
