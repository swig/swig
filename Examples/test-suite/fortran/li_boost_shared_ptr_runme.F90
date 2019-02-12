! File : li_boost_shared_ptr_runme.f90

#include "fassert.h"

program li_boost_shared_ptr_runme
  use li_boost_shared_ptr
  use ISO_C_BINDING
  implicit none
  type(Klass) :: f1, f2
  integer(c_int) :: orig_total_count
  integer(c_int) :: memory_leak

  !call set_debug_shared(.true.)

  ! The getTotal_count function is static, so 'f2' doesn't have to be allocated
  orig_total_count = f1%getTotal_count()
  
  ASSERT(use_count(f1) == 0)
  ASSERT(f1%getTotal_count() == orig_total_count)
  f1 = Klass() ! Construct
  ASSERT(f1%getTotal_count() == orig_total_count + 1)
  ASSERT(use_count(f1) == 1)
  f2 = f1 ! Copy shared pointer, not underlying object
  ASSERT(use_count(f1) == 2)
  ASSERT(use_count(f2) == 2)

  f2 = Klass() ! Create a new object, assigning the *shared pointer*
               ! but not replacing the underlying object.
  ASSERT(use_count(f1) == 1)
  ASSERT(use_count(f2) == 1)

  f1 = pointertest(f2) ! Return a non-shared pointer
                       ! and call the destructor of C++ object 1
  ASSERT(use_count(f2) == 1)

  call f1%release() ! Clear the raw pointer (does not deallocate)
  ASSERT(use_count(f1) == 0)

  ! Copy-construct the underlying object
  f1 = Klass(f2)
  ASSERT(use_count(f1) == 1)
  ASSERT(use_count(f2) == 1)
  call f1%release()

  call f2%release() ! Destroy the last existing shared pointer
                    ! which then destroys the C++ object 2
  ASSERT(use_count(f2) == 0)

  call f2%release() ! Further calls to release() are allowable null-ops

  ! Create a temporary shared pointer that's passed into a function
  ! THIS LEAKS MEMORY!
  ASSERT(use_count(Klass()) == 1)
  memory_leak = 1

  ! The getTotal_count function is static, so 'f2' doesn't have to be allocated
  ASSERT(f2%getTotal_count() == orig_total_count + memory_leak)
end program

