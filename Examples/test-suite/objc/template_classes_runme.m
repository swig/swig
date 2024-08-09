#import "template_classes_proxy.h"

int main(int argc,char* argv[])
{
NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
RectangleInt *rectint=[[RectangleInt alloc]init];
PointInt *pi=[rectint getPoint];
int x=[pi getX];

[rectint release];
[pool drain];
return 0;
}

