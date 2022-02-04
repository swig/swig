! File : runme.f90
#define ASSERT(conditional) \
if (.not. conditional) then; \
  stop 1; \
endif


program test_static
use example

type(BaseClass), target :: v1
type(BaseClass), target :: v2

! Set variables
v1 = BaseClass()
call v1%set_i(2)
ASSERT(v1%get_i() == 2)

v2 = BaseClass()
call v2%set_i(3)
ASSERT(v1%get_i() == 3)
ASSERT(v2%get_i() == 3)

ASSERT(v1%f(1) == 2.0)
ASSERT(v2%f(2) == 4.0)

call v1%release()
call v2%release()

end program

