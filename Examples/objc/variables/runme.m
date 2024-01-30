
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	//Try to set the values of global variables
	setIvar(42);
	setSvar(-31000);
	setLvar(65537);
	setUivar(123456);
	setUsvar(61000);
	setUlvar(654321);
	setScvar(-13);
	setUcvar(251);
	setDvar(0);
	setCvar('S');
	setFvar(3.14159);		 
	setStrvar(@"Hello World");
	setIptrvar(ObjcNew_int(37));
	setPtptr(ObjcNew_TPoint(37,42));
	setName(@"Bill");
	
	//Now print out the values of variables
	
	NSLog(@"Variables (values printed from Objective C)\n");
	
	NSLog(@"ivar      = %i\n",getIvar());
	NSLog(@"svar      = %i\n", getSvar());
	NSLog(@"lvar      = %li\n", getLvar());
	NSLog(@"uivar     = %u\n", getUivar());
	NSLog(@"usvar     = %u\n", getUsvar());
	NSLog(@"ulvar     = %lu\n", getUlvar());
	NSLog(@"scvar     = %i\n", getScvar());
	NSLog(@"ucvar     = %u\n", getUcvar());
	NSLog(@"fvar      = %g\n", getFvar());
	NSLog(@"dvar      = %g\n", getDvar());
	NSLog(@"cvar      = %c\n", getCvar());
	NSLog(@"strvar    = %@\n", getStrvar());
	NSLog(@"iptrvar    =%p\n", getIptrvar());
	NSLog(@"name      = %@\n", getName());
	NSLog(@"ptptr     = %p %@\n", getPtptr(), ObjcTPoint_print(getPtptr()));	
        NSLog(@"pt        ="); ObjcPt_print();
	NSLog(@"status    = %d\n", getStatus());
	
	
	NSLog(@"\nVariables (values printed from C)\n");
	ObjcPrint_vars();
	
        // This line would not compile: since status is marked with
	// %immutable, there is no SetStatus function.
	// NSLog(@"\nNow I'm going to try and modify some read only variables")
	// setStatus(0)
		
	NSLog(@"\nI'm going to try and update a structure variable.\n");
	
	setPt((struct SWIGTYPE_TPoint*)getPtptr());
	
	NSLog(@"The new value is \n");
	
	ObjcPt_print();
	NSLog(@"You should see the value %@",ObjcTPoint_print(getPtptr())); 
        
        [pool drain];
	return 0;
}
