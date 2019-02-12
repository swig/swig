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
  type(Foo) :: a, b

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%mem == 0)

  a = Foo(123)
  ASSERT(c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%mem == 1)

  b = get_reference(a)
  ASSERT(c_associated(b%swigdata%cptr))
  ASSERT(b%swigdata%mem == 4) ! SWIG_CREF

  ! Release reference, but don't deallocate a
  call b%release()
  ASSERT(.not. c_associated(b%swigdata%cptr))
  ASSERT(b%swigdata%mem == 0)

  call a%release()
  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%mem == 0)

end subroutine

subroutine test_assignment
  use cpp_basic
  use ISO_C_BINDING
  implicit none
  type(Foo) :: a, b, c

  ASSERT(.not. c_associated(a%swigdata%cptr))
  ASSERT(a%swigdata%mem == 0)

  ! Create
  a = Foo(123)
  ASSERT(a%func1(3) == 2 * 3 * 123)
  ! Copy
  b = a
  ASSERT(b%func1(3) == 2 * 3 * 123)
  ! Assign null, deleting object
  a = c
  ! 'b' is a reference to deleted data, but it shouldn't crash when we clear it
  call b%release()
end subroutine
end program

