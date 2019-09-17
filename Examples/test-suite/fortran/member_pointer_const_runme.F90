! File : member_pointer_const_runme.F90

#include "fassert.h"

program member_pointer_const_runme
  use member_pointer_const
  use ISO_C_BINDING
  implicit none

  type(SwigOpaqueMemFunPtr) :: area_memptr, perim_memptr
  type(Square) :: s
  real(C_DOUBLE) :: val

  ! Call C functions that return the member function pointers
  area_memptr = areapt()
  perim_memptr = perimeterpt()

  ! Allocate a square
  s = Square(10.0d0)

  ! Call a function that takes a member function pointer and an object
  val = do_op(s, area_memptr)
  call check("Square area", 100.0_C_DOUBLE, val)

  ! Get a function pointer via a global variable
  area_memptr = get_areavar()
  val = do_op(s, area_memptr)
  call check("Square area", 100.0_C_DOUBLE, val)

  ! Change the function pointer
  call set_areavar(perim_memptr)
  val = do_op(s, get_areavar())
  call check("Square perimimter", 40.0_C_DOUBLE, val)

  ! Try the external constants
  perim_memptr = PERIMPT
  val = do_op(s, get_areavar())
  call check("Square perimimter", 40.0_C_DOUBLE, val)

contains

  subroutine check(what, expected, actual)
    character(len=*), intent(in) :: what
    real(C_DOUBLE), intent(in) :: expected, actual
    if (actual /= expected) then
      write(*, *) "Failed: ", what, " Expected: ", expected, &
                  " Actual: ", actual
      stop 1
    end if
  end subroutine check

end program
