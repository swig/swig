! File : ccomplextest_runme.F90

#include "fassert.h"

program ccomplextest_runme
  use ccomplextest
  use ISO_C_BINDING
  implicit none
  complex(C_FLOAT_COMPLEX) :: cflt
  complex(C_DOUBLE_COMPLEX) :: cdbl 
  logical :: do_test = .false.

  ! Older compilers just wrap the calls, but the C code fails
  if (has_c99_complex() == 1) do_test = .true.

  cflt = (1, 3) ! 1 + 3i
  cflt = Conjf(cflt)
  if (do_test) then
      ASSERT(cflt == (1, -3))
  endif

  cdbl = (4.0000000001d0, 1d0)
  if (do_test) then
      ASSERT(Conj(cdbl) == (4.0000000001d0, -1d0))
  endif

  cdbl = (4, 5)
  cdbl = Conj2(cdbl)
  if (do_test) then
      ASSERT(cdbl == (4d0, -5d0))
  endif

end program


