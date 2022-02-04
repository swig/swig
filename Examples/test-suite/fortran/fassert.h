#define ASSERT(COND) \
if(.not.(COND))then;print*,"Failure:",__LINE__;stop 1;end if
