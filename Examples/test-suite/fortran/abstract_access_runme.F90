! File : abstract_access_runme.F90

#include "fassert.h"

program abstract_access_runme
  use abstract_access
  use ISO_C_BINDING
  implicit none
  type(D), target :: dcls
  class(A), pointer :: basecls => NULL()
  dcls = D()
  basecls => dcls

  ASSERT(basecls%do_x() == 1)
end program

