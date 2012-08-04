
#import "example_proxy.h"

int main(int argc, char* argv[]) {
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	

    // Object creation
    Vector *v1 =[[Vector alloc]initWithX:3.0 y:4.0 z:5.0];
    Vector *v2 =[[Vector alloc]initWithX:10.0 y:11.0 z:12.0];
        
    NSLog(@"Created v1 %@",[v1 Vector_print]);
    NSLog(@"Created v2 %@",[v2 Vector_print]);
        
    // Call an overloaded operator
    NSLog(@"Adding a+b \n");
    Vector *v3 =ObjcAddv(v1 ,v2);
    NSLog(@"a+b =   %@",[v3 Vector_print]);
        
    // Create a vector Array
    NSLog(@"Creating an array of vectors\n");
    VectorArray *va=[[VectorArray alloc]initWithMaxsize:10];
    NSLog(@" va:size %i",[va VectorArray_size]);
        
    // Copy the value of v1 and v2 to a vector array
    [va VectorArray_set:0 a:v1];
    [va VectorArray_set:1 a:v2];
    [va VectorArray_set:2 a:ObjcAddv(v1,v2)];
        
    // Get some values from the array
    NSLog(@"Getting some array values \n");
    int i =0;
    for(i=0; i<5 ;i++)
    {
        Vector *v4=[va VectorArray_get:i];
        NSLog(@"Array element %@",[v4 Vector_print]);
    }
        
    // Clean up
    [v1 release];
    [v2 release];
    [va release];
    [pool drain];
        
   return 0;
 }
