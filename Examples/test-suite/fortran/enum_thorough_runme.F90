! File : enum_thorough_runme.F90

#include "fassert.h"

program enum_thorough_runme
  use enum_thorough
  use ISO_C_BINDING
  implicit none
  ! Test that the enum type is created 
  integer(IgnoreTest_ignoreA) :: val

  ! Test that ignoring values preserves later values
  ASSERT(IgnoreTest_ignoreA_zero == 0)
  ASSERT(IgnoreTest_ignoreA_three == 3)
  ASSERT(IgnoreTest_ignoreA_thirty_two == 32)

  val = ignoreATest(IgnoreTest_ignoreA_three)
  ASSERT(val == 3)
end program


