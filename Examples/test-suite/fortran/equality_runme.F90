! File : equality_runme.F90

#include "fassert.h"

program equality_runme
  use equality
  use ISO_C_BINDING
  implicit none
  type(EqualOpDefined) :: a
  type(EqualOpDefined) :: b

  a = EqualOpDefined(5)
  b = EqualOpDefined() ! default in C++ is 5
  ASSERT(a%get_x() == b%get_x())
  ASSERT(a == b)
  ! ASSERT(a /= b) No inequality operator is defined
  call b%set_x(4)
  ASSERT(.not. (a == b))

end program


