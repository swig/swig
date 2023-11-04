! File : ignore_parameter_runme.F90

#include "fassert.h"

program ignore_parameter_runme
  use ignore_parameter
  use ISO_C_BINDING
  implicit none
  ASSERT(jaguar(200, 0.0d0) == "hello")

  ASSERT(get_called_argout() == 0)
  ASSERT(lotus("fast", 0.0d0) == 101)
  ASSERT(get_called_argout() == 1)
end program


