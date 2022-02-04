! File : complextest_runme.F90

#include "fassert.h"

program complextest_runme
  use complextest
  use ISO_C_BINDING
  implicit none
  complex(C_FLOAT_COMPLEX) :: cflt
  complex(C_DOUBLE_COMPLEX) :: cdbl 
  type(VectorStdCplx) :: vec

  cflt = (1, 3) ! 1 + 3i
  cflt = Conjf(cflt)
  ASSERT(cflt == (1, -3))
  cdbl = (4.0000000001d0, 1d0)
  ASSERT(Conj(cdbl) == (4.0000000001d0, -1d0))

  cdbl = (4, 5)
  cdbl = Conj2(cdbl)
  ASSERT(cdbl == (4d0, -5d0))

  vec = VectorStdCplx(10)
  call vec%set(5, cmplx(4, -5, kind=C_DOUBLE_COMPLEX))
  ASSERT(vec%get(5) == cdbl)
end program


