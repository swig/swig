! File : fortran_ownership_runme.F90

#include "fassert.h"

program fortran_ownership_runme
  use ISO_C_BINDING
  implicit none

  call test_standard
  call test_shared

contains

! Test a standard C++ object that's not marked as a shared pointer
subroutine test_standard
  use fortran_ownership
  implicit none
  type(Foo) :: a, b, c

  a = Foo(1) ! Create a new object
  b = Foo(a) ! Create a new *copy* of a
  call b%set_val(2) ! Setting 'b' is independent of 'a'
  ASSERT(a%get_val() == 1)

  call b%release() ! Release by assigning a 'null' object

  c = reference(a) ! Custom function: c refers to data owned by 'a'
  call a%set_val(3)
  ASSERT(c%get_val() == 3)

  a = Foo(4) ! "Move"-assign new value to 'a'
  ASSERT(c%get_val() == 4) ! The reference is changed as well

  b = Foo(a) ! Another way of copying 'a'
  call b%set_val(5)
  ASSERT(a%get_val() == 4) ! The data in 'a' is unchanged

  call a%release() ! Free data pointed to by 'a'
  ! call c%set_val(5) ! XXX This would crash
  call c%release() ! Release by assigning 'null'

end subroutine

! Test a shared pointer (e.g. TeuchosRCP<MultiVector>)
subroutine test_shared
  use fortran_ownership
  implicit none
  type(Bar) :: a, b, c

  a = Bar(1) ! Create a new object
  ASSERT(use_count(a) == 1) ! Create a new object

  b = share(a) ! Create a new *shared pointer* copy of a
  ASSERT(use_count(a) == 2)
  call b%set_val(2) ! Setting 'b' changes 'a'
  ASSERT(a%get_val() == 2)

  ! b = empty ! CAN'T Release by assigning a 'null' object
  call b%release() ! Release by assigning a 'null' object
  ASSERT(use_count(a) == 1)

  c = share(a) ! Custom function: duplicate the shared pointer
  ASSERT(use_count(a) == 2)
  call a%set_val(3)
  ASSERT(c%get_val() == 3)

  ! b = c ! CAN'T copy-construct: b is unassigned so we can't use assignment
  b = share(a)
  ASSERT(use_count(a) == 3)

  a = Bar(4) ! Create a new object and bind to 'a'
  ASSERT(use_count(a) == 1)
  ASSERT(use_count(b) == 2) ! 'b' and 'c' still point to the same data
  ASSERT(c%get_val() == 3)

  call b%release()
  b = Bar(a) ! Copy 'a', creating a new object that's bound to 'b'
  ASSERT(use_count(b) == 1)
  call a%set_val(5) ! Changing 'a' does not affect 'b'
  ASSERT(b%get_val() == 4)

  call a%release() ! Release reference to data pointed to by 'a'
  call c%set_val(5) ! This doesn't crash because pointers are shared
  ! c = empty ! CAN'T Release by assigning 'null'
  call c%release()
end subroutine

end program

