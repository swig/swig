! File : extend_variable_runme.F90

#include "fassert.h"

program extend_variable_runme
  use extend_variable
  use ISO_C_BINDING
  implicit none
  type(ExtendMe) :: em
  type(Foo) :: f

  ! Test fake member variable
  em = ExtendMe()
  call em%set_ExtendVar(10.0d0)
  ASSERT(em%get_ExtendVar() == 10.0d0)
  call em%release()

  ! Test fake static const int ('nopass' means we don't have to create)
  ASSERT(f%get_StaticConstInt() == 2222)

  ! Test extended class constants, both hard-coded and linked
  ASSERT(Foo_Bar == 42)
  ASSERT(Foo_AllBarOne == 4422)

end program


