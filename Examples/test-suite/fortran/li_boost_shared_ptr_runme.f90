! File : li_boost_shared_ptr_runme.f90

#include "fassert.h"

program li_boost_shared_ptr_runme
  use ISO_C_BINDING
  implicit none
  call test_ptrs

contains

subroutine test_ptrs
  use li_boost_shared_ptr
  use ISO_C_BINDING
  implicit none

  class(Klass), allocatable :: k
  class(Klass2ndDerived), allocatable :: ksub

  allocate(k, source=Klass2ndDerived("poop on a stick"))
  allocate(ksub, source=Klass2ndDerived("two poops"))

  write (*,*) use_count(k)
  write (*,*) overload_rawbyval(k)
  write (*,*) overload_smartbyval(k)
  write (*,*) overload_smartbyref(k)

  write (*,*) use_count(ksub)
  write (*,*) overload_rawbyval(ksub)

  ! ASSERT(use_count(k) == 1)

end subroutine
end program

