#define ASSERT(COND) \
if (.not. (COND)) then ; write(0,'(A,I3)') "Failure at line ", __LINE__ ; stop 1 ; end if
