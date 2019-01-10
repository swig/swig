! File : extend_variable_runme.f90

program extend_variable_runme
  use extend_variable
  use ISO_C_BINDING
  implicit none
  type(ExtendMe) :: em
  type(Foo) :: f

  ! Test fake member variable
  em = ExtendMe()
  call em%set_ExtendVar(10.0d0)
  if (em%get_ExtendVar() /= 10.0d0) stop 1
  call em%release()

  ! Test fake static const int ('nopass' means we don't have to create)
  if (f%get_StaticConstInt() /= 2222) stop 1

  ! Test extended class constants, both hard-coded and linked
  if (Foo_Bar /= 42) stop 1
  if (Foo_AllBarOne /= 4422) stop 1

end program


