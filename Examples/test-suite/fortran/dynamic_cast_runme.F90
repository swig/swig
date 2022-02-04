! File : dynamic_cast_runme.F90

#include "fassert.h"

program dynamic_cast_runme
  implicit none

  call test_dynamic_cast

contains
subroutine test_dynamic_cast
  use dynamic_cast
  use ISO_C_BINDING
  implicit none
  type(Foo) :: f
  class(Foo), allocatable :: b
  type(Bar) :: fref, bref

  f = Foo()
  ! Allocate polymorphic Fortran 'Bar' class as a 'Foo' class
  allocate(b, source=Bar())

  ! Obtain downcast references
  fref = f%blah()
  bref = b%blah()

  ASSERT(.not. c_associated(fref%swigdata%cptr))
  ASSERT(c_associated(bref%swigdata%cptr))

end subroutine
end program

