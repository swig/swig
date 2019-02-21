! File : template_array_numeric_runme.F90

#include "fassert.h"

program template_array_numeric_runme
  use template_array_numeric
  use ISO_C_BINDING
  implicit none

  call test_assignment

contains
subroutine test_assignment
  use template_array_numeric
  use ISO_C_BINDING
  implicit none
  type(Array4f) :: a, b, empty
  real(C_FLOAT), dimension(4) :: nums = [1., 2., 4., 8.]

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%mem == 0)

  ! Create
  a = Array4f(nums)
  ASSERT(a%swigdata%mem == 1) ! SWIG_OWN
  ! Copy-construct
  b = a
  ASSERT(c_associated(b%swigdata%cptr))
  ASSERT(.not. c_associated(b%swigdata%cptr, a%swigdata%cptr))
  ASSERT(b%swigdata%mem == 1) ! SWIG_OWN
  ! Assign (TODO): assignment isn't found in class definition
  !b = a
  ! Assign from function result
  a = empty
  a = make_array4f(nums)
  call a%release()
  call b%release()
end subroutine
end program

