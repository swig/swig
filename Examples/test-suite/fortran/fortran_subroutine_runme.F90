! File : fortran_subroutine_runme.F90

#include "fassert.h"

program fortran_subroutine_runme
  use ISO_C_BINDING
  implicit none

  call test_cls
  call test_free

contains

! Test functionality of a class
subroutine test_cls
  use fortran_subroutine
  use ISO_C_BINDING
  implicit none
  type(FooInt) :: f
  integer(C_INT) :: ierr

  f = FooInt()
  call f%val(2)
  call f%treble(ierr)
  ASSERT(ierr == 0)
  call f%treble()
  ASSERT(f%get_val() == 2 * 3 * 3)
  call f%val(-4)
  call f%treble(ierr)
  ASSERT(ierr == 1)
  ASSERT(f%get_val() == -4)

  ! Note: automatically prevented from becoming a subroutine
  f = make_foo(3)
  call f%release()

end subroutine

! Test free functions
subroutine test_free
  use fortran_subroutine
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: j = 4, k = -1

  ! Multiply and obtain return value
  call multiply(2, 4, k)
  ASSERT(k == 8)

  ! No return value specified
  call multiply(3, 6)

  ! Check that these aren't changed
  call already_a_subroutine(123, j)
  ASSERT(j == 123)
  ASSERT(still_a_function())

end subroutine

end program

