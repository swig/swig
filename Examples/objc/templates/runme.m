
#import "example_proxy.h"

int main(int argc, char* argv[]) {
	NSAutoreleasePool *pool =[[NSAutoreleasePool alloc]init];
	
	//Call some templated functions
    NSLog(@"The value returned by maxint is %i",ObjcMaxint(3,7));
    NSLog(@"The value returned by maxdouble is %g",ObjcMaxdouble(3.14,2.18));


    //Create some class
    vecint *iv =[[vecint alloc]initWith_sz:100];
    vecdouble *dv=[[vecdouble alloc]initWith_sz:1000];
    int i=0;
    for (i=0;i<100;i++)
        [iv setitem:i val:2*i];

    for (i=0;i<1000;i++)
        [dv setitem:i val:1.0/(i+1)];

    {
        int sum =0;
        for (i=0;i<100;i++)
            sum=sum+[iv getitem:i];
        NSLog(@"The sum of integers: %i",sum);   
    }
    
    {
        double sum =0;
        for (i=0;i<1000;i++)
            sum=sum+[dv getitem:i];
        NSLog(@"The sum of doubles: %f",sum);   
    }

    [iv release];
    [dv release];
    [pool drain];

    return 0;
 }
