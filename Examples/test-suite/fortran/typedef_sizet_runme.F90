! File : typedef_sizet_runme.F90

#include "fassert.h"

program typedef_sizet_runme
  use typedef_sizet
  use ISO_C_BINDING
  implicit none
  integer(C_SIZE_T) :: inp, outp

  inp = 1234_c_size_t
  outp = identity_size(inp)
  ASSERT(inp == outp)
end program
