! File : template_basic_runme.F90

#include "fassert.h"

program template_basic_runme
  use template_basic
  use ISO_C_BINDING
  implicit none

  call test_assignment

contains
subroutine test_assignment
  use template_basic
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: val
  type(vecint) :: a, b, empty

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%mem == 0)

  ! Create
  a = vecint(3)
  ASSERT(a%swigdata%mem == 1) ! SWIG_OWN

  val = 2
  call a%set(0, val)
  ASSERT(a%get(0) == 2)
  ! Copy
  b = a
  val = 5
  call a%set(0, val)
  ASSERT(a%get(0) == 5)
  ASSERT(b%get(0) == 2)
  ! Assign null, deleting object
  a = empty
  call b%release()
end subroutine
end program

