
#import "example_proxy.h"

int main(int argc, char* argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // ----- Object creation -----
    NSLog(@"Creating some objects:" );
    Circle *c = [[Circle alloc] initWithR: 10];
    NSLog(@"Created circle %@", c );

    Square *s = [[Square alloc] initWithW: 10];
    NSLog(@"Created square %@", s );

    // ----- Access a static member -----
    NSLog(@"\nA total of %d shapes were created", [Shape getNshapes]);


    // ----- Member data access -----
    // Notice how we can do this using functions specific to
    // the 'Circle' class.
    [c setX: 20];
    [c setY: 30];


    // Now use the same functions in the base class
    Shape *shape = s;
    [shape setX: -10];
    [shape setY: 5];

    NSLog(@"\nHere is their current position:" );
    NSLog(@"Circle = (%f, %f)",[c getX], [c getY]);
    NSLog(@"Square = (%f, %f)",[s getX], [s getY]);
    
    // ----- Call some methods -----
    NSLog(@"\nHere are some properties of the shapes:" );
    NSMutableArray *shapes = [[NSMutableArray alloc] init];
    [shapes addObject: c];
    [shapes addObject: s];

    int i;
    Shape *obj = nil;
    // Notice how the area() and perimeter() functions really
    // invoke the appropriate virtual method on each object.
    for(i=0; i<[shapes count]; i++)
    {
        obj = [shapes objectAtIndex: i];
        NSLog(@"Shape: %@", obj);
        NSLog(@"area      = %f", [obj area]);
        NSLog(@"perimeter = %f", [obj perimeter]);
    }

    // ----- Delete everything -----
    // Note: this invokes the virtual destructor
    // You could leave this to the garbage collector
    [c release];
    [s release];
    NSLog(@"%d shapes remain", [Shape getNshapes]);

    [shapes release];
    [pool release];
   return 0;
 }

