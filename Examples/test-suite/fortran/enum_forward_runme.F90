! File : enum_forward_runme.F90

#include "fassert.h"

program enum_forward_runme
  use enum_forward
  use ISO_C_BINDING
  implicit none
  ! C-bound enums are treated as C integers
  integer(C_INT) :: f1, f2, f3

  f1 = get_enum1()
  f1 = test_function1(f1)

  f2 = get_enum2()
  f2 = test_function2(f2)

  f3 = get_enum3()
  f3 = test_function3(f3)

end program


