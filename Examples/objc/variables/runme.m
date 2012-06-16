
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
	setIptrvar(new_int(37));
	setPtptr(new_Point(37,42));
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
	getIptrvar();
	NSLog(@"name      = %@\n", getName());
	NSLog(@"ptptr     = %@\n", Point_print(getPtptr()));
	
	
	NSLog(@"\nVariables (values printed from C)\n");
	print_vars();
	
	NSLog(@"\nNow I'm going to try and modify some read only variables\n");
	NSLog(@"     Tring to set 'path'\n");
	
	NSLog(@"  'path is' %@",getPath());
	
	
	NSLog(@"     Trying to set 'status '\n");
	NSLog(@"  'Status is' %i",getStatus());
	
	NSLog(@"\nI'm going to try and update a structure variable.\n");
	
	setPt(getPtptr());
	
	NSLog(@"The new value is \n");
	
	pt_print();
	
	NSLog(@"You should see the value %@",Point_print(getPtptr())); 
	
	[pool drain];
	return 0;
}
