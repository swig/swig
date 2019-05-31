! File : funcptr_runme.F90

#include "fassert.h"

program funcptr_runme
  use funcptr
  use ISO_C_BINDING
  implicit none
  type(C_FUNPTR) :: fp

  ! Add
  call set_handle(0, fp)
  ASSERT(do_op(2, 3, fp) == 5)

  ! Subtract
  call set_handle(1, fp)
  call set_funcvar(fp)
  ASSERT(do_op(2, 3, get_funcvar()) == -1)

end program

