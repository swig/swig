
#import "exampleProxy.h"

int main(int argc, char* argv[]) {
   NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
   Circle *c = [[Circle alloc] initWithR: 2.0];
   NSLog(@"Area of circle is %f\n", [c area]);
   [c move:4 dy:5];
   
   Square *s = [[Square alloc] initWithW: 3.0];
   NSLog(@"Perimiter of the square is %f\n", [s perimeter]);
   NSLog(@"Number of shapes created = %d", [Shape getNshapes]);
   [c release];
   [s release];
   [pool release];
   return 0;
}
