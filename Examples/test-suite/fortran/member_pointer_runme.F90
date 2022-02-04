! File : member_pointer_runme.F90

#include "fassert.h"

program member_pointer_runme
  use member_pointer
  use ISO_C_BINDING
  implicit none
  type(SWIGTYPE_m_Shape__f_void__double) :: area_memptr, perim_memptr
  type(Square) :: s
  real(C_DOUBLE) :: val

  ! Call C functions that return the member function pointers
  area_memptr = areapt()
  perim_memptr = perimeterpt()

  ! Allocate a square
  s = Square(10.0d0)

  ! Call a function that takes a member function pointer and an object
  val = do_op(s, area_memptr)
  ASSERT(val == 100.0d0)

  ! Get a function pointer via a global variable
  area_memptr = get_areavar()
  val = do_op(s, area_memptr)
  ASSERT(val == 100.0d0)

  ! Change the function pointer
  call set_areavar(perim_memptr)
  val = do_op(s, get_areavar())
  ASSERT(val == 40.0d0)
end program


