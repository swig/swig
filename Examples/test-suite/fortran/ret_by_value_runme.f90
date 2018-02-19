program ret_by_value_runme

  use ret_by_value
  use iso_fortran_env
  use iso_c_binding

  type(test) :: test_val
  logical :: okay
  integer(c_short) :: short
  integer(c_int) :: int

  okay = .true.

  test_val = get_test()

  int = test_val%myInt
  short = test_val%myShort

  if(test_val%myInt /= 100) then
    write(*,*)"Wrong value for %myInt",100
    okay = .false.
  endif

  if(test_val%myShort /= 200) then
    write(*,*)"Wrong value for "
    okay = .false.
  endif


  if(.not.okay) then
    stop 1
  endif
end program
