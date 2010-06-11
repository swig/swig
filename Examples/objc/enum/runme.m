
#import "exampleProxy.h"

int main(int argc, char* argv[]) {
	// Print out the value of some enums
	NSLog(@"*** color ***");
 	NSLog(@"color::RED =%d", RED);
 	NSLog(@"color::BLUE =%d", BLUE);
	NSLog(@"color::GREEN =%d", GREEN);

 	NSLog(@"\n*** Foo::speed ***");
 	NSLog(@"speed::IMPULSE =%d", IMPULSE);
 	NSLog(@"speed::WARP =%d", WARP);
 	NSLog(@"speed::LUDICROUS =%d", LUDICROUS);

	NSLog(@"\nTesting use of enums with functions\n");

	enum_test(RED, IMPULSE);
  	enum_test(BLUE, WARP);
  	enum_test(GREEN, LUDICROUS);

  	NSLog(@"\nTesting use of enum with class method" );
  	Foo* f = [[Foo alloc] init];

  	[f enum_test:IMPULSE];
  	[f enum_test:WARP];
  	[f enum_test:LUDICROUS];
    [f release];
	return 0;
}
