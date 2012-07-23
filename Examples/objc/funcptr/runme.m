
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	
 int a = 37;
 int b = 42;
    
   // Now call our C function with a bunch of callbacks
   NSLog(@"Trying some C callback functions" );
   NSLog(@"a        = ", a );
   NSLog(@"b        = ", b );
   NSLog(@"ADD(a,b) = ", ObjcDo_op(a,b,example.ADD) );
   NSLog(@"SUB(a,b) = ", ObjcDo_op(a,b,example.SUB) );
   NSLog(@"MUL(a,b) = ", ObjcDo_op(a,b,example.MUL) );
    
   NSLog(@"Here is what the C callback function classes are called in Java" );
   NSLog(@"ADD      = ", example.ADD.getClass().getName() );
   NSLog(@"SUB      = ", example.SUB.getClass().getName() );
   NSLog(@"MUL      = ", example.MUL.getClass().getName() );
   return 0;
}
