! File : global_vars_runme.f90

program global_vars_runme
  use global_vars
  use ISO_C_BINDING
  implicit none

  ! Initialize global vars
  call init()

  ! Test string conversion
  if (get_b() /= "string b") stop 1
  call set_b("blorp")
  if (get_b() /= "blorp") stop 1

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
