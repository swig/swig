! File : fortran_overloads_runme.F90

#include "fassert.h"

program fortran_overloads_runme
  use ISO_C_BINDING
  implicit none

  call test_derived
contains

subroutine test_derived  
  use fortran_overloads
  use ISO_C_BINDING
  implicit none
end subroutine
end program


