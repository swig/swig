! File : inctest_runme.F90

#include "fassert.h"

program inctest_runme
  use inctest
  use ISO_C_BINDING
  implicit none
  character(len=:), allocatable :: instr, outstr
  ! If the 'includes' fail, these will produce compiler errors
  type(A) :: ai
  type(B) :: bi

  ai = A()
  call ai%release()

  bi = B()
  call bi%release()
  
  ASSERT(importtest1(5) == 15)

  ! XXX since importtest2 modifies by reference, we should have to copy it out (so that 'instr' is "white" as well)
  allocate(instr, source="black")
  outstr = importtest2(instr)
  ASSERT(outstr == "white")

end program


