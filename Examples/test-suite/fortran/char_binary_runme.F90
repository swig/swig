! File : char_binary_runme.F90

#include "fassert.h"

program char_binary_runme
  use char_binary
  use ISO_C_BINDING
  implicit none
  character(kind=C_CHAR, len=*), parameter :: withnull = "hil" // C_NULL_CHAR
  type(Test) :: t

  if (len(withnull) /= 4) stop 2

  t = Test()
  ASSERT(t%strlen("hile") == 4)
  ASSERT(t%ustrlen("hile") == 4)

  ASSERT(t%strlen(withnull) == 4)
  ASSERT(t%ustrlen(withnull) == 4)

end program


