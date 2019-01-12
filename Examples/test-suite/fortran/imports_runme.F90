! File : imports_runme.F90

#include "fassert.h"

program imports_runme
  use imports_a
  use imports_b
  use ISO_C_BINDING
  implicit none
  type(A) :: aa, a1, a2
  type(B) :: bb
  type(C) :: cc

  bb = B()
  call bb%hello()

  aa = A()

  cc = C()
  a1 = cc%get_a(cc)
  a2 = cc%get_a_type(cc)

  call a1%hello()
  call a2%hello()

  call aa%release()
  call bb%release()
  call cc%release()
  call a1%release()
  call a2%release()
end program


