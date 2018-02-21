! File : ret_by_value_runme.f90

program ret_by_value_runme
  use ret_by_value
  use ISO_C_BINDING
  implicit none

  type(test) :: test_val
  integer(C_SHORT) :: short
  integer(C_INT) :: int

  test_val = get_test()

  int = test_val%myInt
  short = test_val%myShort

  if(test_val%myInt /= 100_C_INT) then
    write(*,*)"Wrong value for %myInt", test_val%myInt
    stop 1
  endif

  if(test_val%myShort /= 200_C_SHORT) then
    write(*,*)"Wrong value for %myShort", test_val%myShort
    stop 1
  endif
end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
