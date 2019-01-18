! File : cpp_basic_runme.F90

#include "fassert.h"

program cpp_basic_runme
  use cpp_basic
  use ISO_C_BINDING
  implicit none
  type(Foo) :: a, b, c

  ! Create
  a = Foo(123)
  ! Copy
  b = a
  ASSERT(b%func1(3) == 2 * 3 * 123)
  ! Assign null, deleting object
  a = c
  ! 'b' is a reference to deleted data, but it shouldn't crash when we clear it
  call b%release()
end program

