! File : li_boost_shared_ptr_runme.f90

#include "fassert.h"

program li_boost_shared_ptr_runme
  use li_boost_shared_ptr
  use ISO_C_BINDING
  implicit none
  type(Klass) :: f1, f2
  integer(c_int) :: orig_total_count

  !call set_debug_shared(.true.)

  ! The getTotal_count function is static, so 'f2' doesn't have to be allocated
  orig_total_count = f1%getTotal_count()
  
  ASSERT(use_count(f1) == 0)
  ASSERT(f1%getTotal_count() == orig_total_count)
  f1 = Klass() ! Construct
  ASSERT(f1%getTotal_count() == orig_total_count + 1)
  ASSERT(use_count(f1) == 1)
  f2 = smartpointertest(f1) ! Copy shared pointer, not underlying object
  ASSERT(use_count(f1) == 2)
  ASSERT(use_count(f2) == 2)
  ! They should be individual shared pointers
  ASSERT(.not. c_associated(f1%swigdata%cptr, f2%swigdata%cptr))
  f2 = f1 ! Copy shared pointer
  ! They should be individual shared pointers
  ASSERT(.not. c_associated(f1%swigdata%cptr, f2%swigdata%cptr))
  ASSERT(use_count(f2) == 2)

  f2 = Klass() ! Create a new object, bind to f2
  ASSERT(use_count(f1) == 1)
  ASSERT(use_count(f2) == 1)

  f1 = pointertest(f2) ! Return a non-shared pointer
  ASSERT(use_count(f2) == 1)

  call f1%release() ! Clear the raw pointer (does not deallocate)
  ASSERT(use_count(f1) == 0)

  ! Test null pointers
  f1 = sp_pointer_null()
  ASSERT(nullsmartpointerpointertest(f1) == "null pointer")
  call f1%release()
  f1 = null_sp_pointer()
  ASSERT(nullsmartpointerpointertest(f1) == "null pointer")
  call f1%release()
  f1 = sp_value_null()
  ASSERT(nullsmartpointerpointertest(f1) == "null pointer")
  call f1%release()

  ! Copy-construct the underlying object
  f1 = Klass(f2)
  ASSERT(use_count(f1) == 1)
  ASSERT(use_count(f2) == 1)
  call f1%release()

  call f2%release() ! Destroy the last existing shared pointer
                    ! which then destroys the C++ object 2
  ASSERT(use_count(f2) == 0)

  call f2%release() ! Further calls to release() are allowable null-ops

  ! The getTotal_count function is static, so 'f2' doesn't have to be allocated
  ASSERT(f2%getTotal_count() == orig_total_count)
end program

