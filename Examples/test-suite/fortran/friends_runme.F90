! File : friends_runme.F90

#include "fassert.h"

program friends_runme
  use friends
  use ISO_C_BINDING
  implicit none
  type(A) :: ai
  type(B) :: bi
  type(D_i) :: di
  type(D_d) :: dd

  ai = A(2)
  ASSERT(get_val1(ai) == 2)
  ASSERT(get_val2(ai) == 4)
  ASSERT(get_val3(ai) == 6)

  ! nice overload working fine
  ASSERT(get_val1(1,2,3) == 1)

  bi = B(3)

  ! david's case
  ASSERT(mix(ai,bi) == 5)

  di = D_i(2)
  dd = D_d(3.3d0)

  ASSERT(get_val1(di) == 2)
  ASSERT(get_val1(dd) == 3.3d0)

  call set(di, 4)
  call set(dd, 1.3d0)

  ASSERT(get_val1(di) == 4)
  ASSERT(get_val1(dd) == 1.3d0)

end program


