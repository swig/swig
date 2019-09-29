! File : funcptr_runme.F90

#include "fassert.h"

module funcptr_mod
  use, intrinsic :: ISO_C_BINDING
  implicit none
contains

function myexp(left, right) bind(C) &
    result(fresult)
  use, intrinsic :: ISO_C_BINDING
  integer(C_INT), intent(in), value :: left
  integer(C_INT), intent(in), value :: right
  integer(C_INT) :: fresult

  fresult = left ** right
end function
  
end module

program funcptr_runme
  use funcptr
  use funcptr_mod
  use ISO_C_BINDING
  implicit none
  procedure(SWIGTYPE_f_int_int__int), pointer :: fp

  ! Get the C++ function handle, which starts out as 'add'
  fp => get_funcvar()
  ASSERT(fp(2, 3) == 5)
  ASSERT(do_op(2, 3, fp) == 5)

  ! Set the function handle
  call set_funcvar(myexp)
  ! Get it back, then call it from C++
  ASSERT(do_op(2, 3, get_funcvar()) == 8)

end program

