! File : runme.f90
program main
  use templated
  implicit none
  type(Thing_Int) it
  type(Thing_Dbl) dt
  it = create_Thing_Int(123)
  call print_thing(it)
  dt = create_Thing_Dbl(456.d0)
  call print_thing(dt)

  call it%release()
  call dt%release()
end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
