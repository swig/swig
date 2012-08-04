#import "bools_proxy.h"
int main(int argc, char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
// bool constant check
if (constbool != false)
    NSLog(@"Runtime test 1 failed\n");
    
//bool variables check
if (getBool1() != YES)
    NSLog(@"Runtime test 2 failed\n");
    
if (getBool2() != NO)
    NSLog(@"Runtime test 3 failed\n");
    
//bool functions check
BOOL b1= ObjcBo(NO);
if (b1 != NO)
    NSLog(@"Runtime test 4 failed\n");
    
BOOL b2=ObjcBo(YES);
if (b2 != YES)
    NSLog(@"Runtime test 5 failed\n");
    
BoolStructure *bs=[[BoolStructure alloc]init];
[bs setM_bool1:YES];
BOOL b4=[bs getM_bool1];
if(b4 !=YES)
NSLog(@"Runtime test 6 failed");

[pool drain];
return 0;
}

