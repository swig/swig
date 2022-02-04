! File : template_array_numeric_runme.F90

#include "fassert.h"

program template_array_numeric_runme
  use template_array_numeric
  use ISO_C_BINDING
  implicit none
  integer, parameter :: swig_cmem_own_bit = 0

  call test_assignment

contains
subroutine test_assignment
  use template_array_numeric
  use ISO_C_BINDING
  implicit none
  type(Array4f) :: a, b, empty
  real(C_FLOAT), dimension(4) :: nums = [1., 2., 4., 8.]

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 0)

  ! Create
  a = Array4f(nums)
  ASSERT(btest(a%swigdata%cmemflags, swig_cmem_own_bit)) ! SWIG_MEM_OWN
  ! Reference
  b = a
  ASSERT(c_associated(b%swigdata%cptr, a%swigdata%cptr))
  ASSERT(.not. btest(b%swigdata%cmemflags, swig_cmem_own_bit)) ! SWIG_MEM_OWN
  ! Assign from function result
  a = empty
  a = make_array4f(nums)
  call a%release()
  call b%release()
end subroutine
end program

