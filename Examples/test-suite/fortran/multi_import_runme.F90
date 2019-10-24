! File : imports_runme.F90

#include "fassert.h"

program imports_runme
  use multi_import_a, only : ZZZ
  use multi_import_b, only : YYY
  use multi_import_d, only : get_myval
  use ISO_C_BINDING
  implicit none
  type(ZZZ) :: z
  type(YYY) :: y

  z = ZZZ()
  ASSERT(z%testz() == 2)
  ASSERT(z%testx() == 0)
  call z%release()

  y = YYY()
  ASSERT(y%testy() == 1)
  ASSERT(y%testx() == 0)
  call y%release()

  ASSERT(get_myval() == 1234)

end program
