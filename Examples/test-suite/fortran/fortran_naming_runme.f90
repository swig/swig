! File : fortran_naming_runme.f90

program fortran_naming_runme
  use fortran_naming
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: test_int
  type(f_Foo) :: myfoo
  type(MyStruct) :: struct

  myfoo = f_Foo()
  call myfoo%release()

  ! NOTE: the 'C' function that's bound is actually named _cboundfunc, so this
  ! will cause a link error if broken
  test_int = 3
  if (f_cboundfunc(test_int) /= (3 + 1)) stop 1 

  ! The member variable has been renamed, but the layout should be the same
  struct%f_y = 4
  if (get_mystruct_y(struct) /= 4) stop 1 

end program


