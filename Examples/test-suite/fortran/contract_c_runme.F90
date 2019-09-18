! File : contract_c_runme.F90

#include "fassert.h"

program contract_c_runme
  use ISO_C_BINDING
  implicit none

  call test_assert
contains

! Test global data
subroutine test_assert
  use contract_c
  use ISO_C_BINDING
  implicit none

  ASSERT(test_preassert(1, 1) == 1)
  ASSERT(test_preassert(-1, 1) == 0)
  ASSERT(ierr == -9)
  ASSERT(len(get_serr()) > 0)
  ierr = 0
  ASSERT(test_postassert(123) == 123)
  ASSERT(test_postassert(-123) == 0)
  ASSERT(ierr == -9)
  ierr = 0
end subroutine

end program
