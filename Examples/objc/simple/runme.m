
#import "example_proxy.h"

int main(int argc, char* argv[]) {
   // Call the gcd() function
    int x = 42;
    int y = 105;
    int g = ObjcGcd(x,y);
    NSLog(@"The gcd of %d and %d is %d\n", x, y, g);
    
    // Manipulate the Foo global variable
    // Output its current value
    NSLog(@"Foo = %f \n", getFoo());
    
    // Change its value
    setFoo(3.1415926);
    
    // See if the change took effect
    NSLog(@"Changed Foo = %f \n", getFoo());

   return 0;
}
