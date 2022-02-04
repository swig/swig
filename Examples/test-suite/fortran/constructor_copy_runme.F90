! File : constructor_copy_runme.F90

#include "fassert.h"

program constructor_copy_runme
  implicit none

  call test_assignment

contains

subroutine test_assignment
  use constructor_copy
  use ISO_C_BINDING
  implicit none
  type(Bari) :: a, b

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 0)

  ! Create
  a = Bari(123)
  ASSERT(a%get_x() == 123)
  ! Copy
  b = Bari(a)
  ! Value should be same, but pointers should not
  ASSERT(b%get_x() == 123)
  ASSERT(.not. c_associated(a%swigdata%cptr, b%swigdata%cptr))

  call b%release()
  call a%release()
end subroutine

end program

