! File : cpp_basic_runme.F90

#include "fassert.h"

program cpp_basic_runme
  use cpp_basic
  use ISO_C_BINDING
  implicit none

  call test_ownership
  call test_assignment

contains
subroutine test_ownership
  use cpp_basic
  use ISO_C_BINDING
  implicit none
  type(Foo) :: a, b, c

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 0)

  a = Foo(123)
  ASSERT(c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 1)

  b = get_reference(a)
  ASSERT(c_associated(b%swigdata%cptr))
  ASSERT(b%swigdata%cmemflags == 0) ! Simple reference

  c = get_const_reference(b)
  ASSERT(c_associated(c%swigdata%cptr, a%swigdata%cptr))

  ! Associate with a new class
  b = Foo(234)
  ASSERT(a%get_num() == 123)
  ASSERT(b%swigdata%cmemflags == 1)

  ! Self-assign reference
  b = b
  ASSERT(c_associated(b%swigdata%cptr))
  ! XXX: when self-assigning, the left becomes a reference, even though it's destroying the right.
  ! ASSERT(b%swigdata%cmemflags == 1)

  ! Release reference
  call b%release()
  ASSERT(.not. c_associated(b%swigdata%cptr))
  ASSERT(b%swigdata%cmemflags == 0)

  call a%release()
  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 0)

  ! Release reference to already-destroyed memory
  call c%release()
  ASSERT(.not. c_associated(c%swigdata%cptr))
  ASSERT(c%swigdata%cmemflags == 0)

end subroutine

subroutine test_assignment
  use cpp_basic
  use ISO_C_BINDING
  implicit none
  type(Foo) :: a, b, c

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%cmemflags == 0)

  ! Create
  a = Foo(123)
  ASSERT(a%func1(3) == 2 * 3 * 123)
  ! Copy
  b = Foo(a)
  ! Value should be same, but pointers should not
  ASSERT(b%func1(3) == 2 * 3 * 123)
  ASSERT(.not. c_associated(a%swigdata%cptr, b%swigdata%cptr))

  ! Get reference to b, then release b
  c = get_reference(b)
  call b%release()
  ! 'c' is a reference to deleted data, but it shouldn't crash when we clear it
  call c%release()
  ! Release 'a's memory
  call a%release()
end subroutine
end program

