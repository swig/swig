! File : operator_overload_runme.F90

#include "fassert.h"

program operator_overload_runme
  implicit none

  call test_operator_overload

contains
subroutine test_operator_overload
  use operator_overload
  use ISO_C_BINDING
  implicit none
  type(Op) :: a, b, c, d

  ! Check that C++ operators are implemented: static function, so doesn't have
  ! to be allocated
  call a%sanity_check()

  a = Op(1)
  b = Op(2)
  c = a + b
  ! XXX: the temporary "Op(3)" leaks memory
  ASSERT(c == Op(3))
  ASSERT(a < b)
  ASSERT(a <= b)
  ASSERT(b > a)
  ASSERT(b >= a)
  ASSERT(b /= a)
  d = c * b
  ASSERT(d == Op(6))
  ASSERT(d%IntCast() == 6)

  ! Test custom modulo operator (as far as I know we can't
  ! override intrinsics)
  c = Op(9)
  d = c .mod. d
  ASSERT(d == Op(3))

  call a%release()
  call b%release()
  call c%release()
  call d%release()
end subroutine
end program

