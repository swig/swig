! File : ret_by_value_runme.F90

#include "fassert.h"

#include "fassert.h"

program ret_by_value_runme
  use ret_by_value
  use ISO_C_BINDING
  implicit none

  type(test) :: test_val
  integer(C_SHORT) :: short
  integer(C_INT) :: int

  test_val = get_test()

  int = test_val%get_myInt()
  short = test_val%get_myShort()

  ASSERT(test_val%get_myInt() == 100_C_INT)
  ASSERT(test_val%get_myShort() == 200_C_SHORT)

end program


