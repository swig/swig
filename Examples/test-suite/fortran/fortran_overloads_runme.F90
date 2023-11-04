! File : fortran_overloads_runme.F90

#include "fassert.h"

program fortran_overloads_runme
  use ISO_C_BINDING
  implicit none

  call test_derived_overloads
contains

subroutine test_derived_overloads 
  use fortran_overloads
  use ISO_C_BINDING
  implicit none
  type(Base) :: basey
  type(DerivedOverloads) :: derived
  integer(C_INT) :: myint = 0
  derived = DerivedOverloads()

  ASSERT(derived%func() == 0)
  ASSERT(derived%func(3) == 3)
  ASSERT(derived%func(4, 5) == 4 - 5)
  call derived%sub(myint)
  ASSERT(myint == 456)

  ! Test non-virtual function overriding
  basey = base_ptr(derived)
  call basey%sub(myint)
  ASSERT(myint == 123)

  call basey%release()
  call derived%release()
end subroutine
end program


