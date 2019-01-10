! File : fortran_naming_runme.f90

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
  if (f_cboundfunc(test_int) /= (3 + 1)) stop 1 

  ! The member variable has been renamed, but the layout should be the same
  struct%m_y = 4
  if (get_mystruct_y(struct) /= 4) stop 1 

  ! The first enum _MYVAL should have priority over the later one
  if (f_MYVAL /= 1) stop 1 

end program


