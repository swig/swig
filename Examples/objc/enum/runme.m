
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	// Print out the value of some enums
	NSLog(@"*** color ***");
 	NSLog(@"color::RED =%d", RED);
 	NSLog(@"color::BLUE =%d", BLUE);
	NSLog(@"color::GREEN =%d", GREEN);

 	NSLog(@"\n*** Foo::speed ***");
 	NSLog(@"speed::IMPULSE =%d",Foo_IMPULSE);
 	NSLog(@"speed::WARP =%d",Foo_WARP);
 	NSLog(@"speed::LUDICROUS =%d",Foo_LUDICROUS);

	NSLog(@"\nTesting use of enums with global function\n");
	ObjcEnum_test(RED,Foo_IMPULSE);
  	ObjcEnum_test(BLUE,Foo_WARP);
  	ObjcEnum_test(GREEN,Foo_LUDICROUS);
   
  	NSLog(@"\nTesting use of enum with class method" );
  	Foo* f = [[Foo alloc] init];

  	[f enum_test:Foo_IMPULSE];
  	[f enum_test:Foo_WARP];
  	[f enum_test:Foo_LUDICROUS];
        [f release];
	
       return 0;
}
