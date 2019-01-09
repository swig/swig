! File : fortran_naming_runme.F90

#include "fassert.h"

program fortran_naming_runme
  use fortran_naming
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: test_int
  type(FooClass) :: myfoo
  type(MyStruct) :: struct

  myfoo = FooClass()
  call myfoo%release()

  ! NOTE: the 'C' function that's bound is actually named _cboundfunc, so this
  ! will cause a link error if broken
  test_int = 3
  ASSERT(f_cboundfunc(test_int) == (3 + 1)) 

  ! The member variable has been renamed, but the layout should be the same
  struct%m_y = 4
  ASSERT(get_mystruct_y(struct) == 4) 

  ! The first enum _MYVAL should have priority over the later one
  ASSERT(f_MYVAL == 1) 

end program


