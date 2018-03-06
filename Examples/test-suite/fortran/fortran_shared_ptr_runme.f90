! File : fortran_shared_ptr_runme.f90

#include "fassert.h"

program fortran_shared_ptr_runme
  use fortran_shared_ptr
  implicit none
  type(Foo) :: f1, f2

  ASSERT(use_count(f1) == 0)
  f1 = Foo(1) ! Construct
  ASSERT(use_count(f1) == 1)
  f2 = f1 ! Copy shared pointer, not underlying object
  ASSERT(use_count(f1) == 2)
  ASSERT(use_count(f2) == 2)

  f2 = Foo(2) ! Create a new object, assigning the *shared pointer*
                     ! but not replacing the underlying object.
  ASSERT(use_count(f1) == 1)
  ASSERT(use_count(f2) == 1)

  f1 = f2%my_raw_ptr() ! Return a non-shared pointer
                       ! and call the destructor of C++ object 1
  ASSERT(use_count(f2) == 1)

  call f1%release() ! Clear the raw pointer (does not deallocate)
  ASSERT(use_count(f1) == 0)
  call f2%release() ! Destroy the last existing shared pointer
                    ! which then destroys the C++ object 2
  ASSERT(use_count(f2) == 0)

  call f2%release() ! Further calls to release() are allowable null-ops
end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
