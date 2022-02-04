! File : enums_runme.F90

#include "fassert.h"

program enums_runme
  use enums
  use ISO_C_BINDING
  implicit none
  integer(foo1) :: foo1_val

  foo1_val = CSP_ITERATION_FWD 
  ASSERT(CSP_ITERATION_FWD == 0)
  ASSERT(CSP_ITERATION_BWD == 11)
  call bar1(CSP_ITERATION_FWD)

  ASSERT(ABCDE == 0)
  ASSERT(FGHJI == 1)
  call bar2(ABCDE)

  ASSERT(globalinstance1 == 0)
  ASSERT(globalinstance3 == 30)

  ASSERT(iFoo_Phoo == 50)
  ASSERT(iFoo_Char == IACHAR('a'))

  ASSERT(slap == 10)
  ASSERT(mine == 11)
  ASSERT(thigh == 12)
end program

