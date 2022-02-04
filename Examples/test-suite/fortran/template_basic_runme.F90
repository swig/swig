! File : template_basic_runme.F90

#include "fassert.h"

program template_basic_runme
  use template_basic
  use ISO_C_BINDING
  implicit none

  call test_assignment

contains

  ! NOTE:  the implementation of the 'vector' in this test case is really broken:
  ! copying doesn't copy the data, and releasing doesn't free the memory.
subroutine test_assignment
  use template_basic
  use ISO_C_BINDING
  implicit none
  type(vecint) :: a, b, empty

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 0)

  ! Create
  a = vecint(3)
  ASSERT(a%swigdata%cmemflags == 1) ! SWIG_MEM_OWN
  ! Copy
  b = a
  ! Assign null, deleting object
  a = empty
  call b%release()
end subroutine
end program

