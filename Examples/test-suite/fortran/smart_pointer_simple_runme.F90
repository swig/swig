! File : smart_pointer_simple_runme.f90

#include "fassert.h"

program smart_pointer_simple_runme
  use smart_pointer_simple
  use ISO_C_BINDING
  implicit none
  type(Foo) :: f, fref
  type(Bar) :: b

  f = Foo()
  b = Bar(f)
  call f%set_x(3)
  ASSERT(b%get_x() == 3)
  fref = .ptr. b

end program
