! File : fortran_global_const_runme.F90

#include "fassert.h"

program fortran_global_const_runme
  use ISO_C_BINDING
  implicit none

  call test_constants
  call test_enums

contains

subroutine test_constants  
  use fortran_global_const
  use ISO_C_BINDING
  implicit none
  ! The following will fail to build if they're not defined as PARAMETERS in the module file
  integer(C_INT), dimension(2), parameter :: compiletime_ints &
    = [ fortranconst_int_global, MACRO_HEX_INT ]
  real(C_FLOAT), dimension(1), parameter :: compiletime_floats &
    = [ fortranconst_float_global ]
  
  integer(C_INT), dimension(:), allocatable :: runtime_ints
  real(C_FLOAT), dimension(:), allocatable :: runtime_floats


  ASSERT(all(compiletime_ints == 4))
  ASSERT(all(compiletime_floats == 1.23))

  allocate(runtime_ints(3), source= &
    [get_nofortranconst_int_global(), MACRO_INT, &
    get_extern_const_int()])
  allocate(runtime_floats(2), source= &
    [constant_float_global, get_nofortranconst_float_global()])

  ASSERT(all(runtime_ints == 4))
  ASSERT(all(runtime_floats == 1.23))
end subroutine

subroutine test_enums  
  use fortran_global_const
  use ISO_C_BINDING
  implicit none
  integer(NativeEnum), dimension(3), parameter :: compiletime_enums &
    = [ Alfa, Sierra, Juliet ]

  ASSERT(compiletime_enums(1) == 0)
  ASSERT(compiletime_enums(2) == 1)

  ! Runtime enums

  ASSERT(Foxtrot == 12345)
  ! Foxtrot = 2 ! ERROR: Foxtrot is PROTECTED
end subroutine
end program


