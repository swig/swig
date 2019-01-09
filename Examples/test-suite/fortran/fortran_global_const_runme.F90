! File : fortran_global_const_runme.f90

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
  integer(C_INT), dimension(4), parameter :: compiletime_ints &
    = [ fortranconst_int_global, constant_int_global, MACRO_INT, MACRO_HEX_INT ]
  real(C_FLOAT), dimension(1), parameter :: compiletime_floats &
    = [ fortranconst_float_global ]
  
  integer(C_INT), dimension(:), allocatable :: runtime_ints
  real(C_FLOAT), dimension(:), allocatable :: runtime_floats


  if (any(compiletime_ints /= 4)) stop 1
  if (any(compiletime_floats /= 1.23)) stop 1

  allocate(runtime_ints(3), source= &
    [nofortranconst_int_global, DEFAULT_MACRO_HEX_INT, &
    get_extern_const_int()])
  allocate(runtime_floats(2), source= &
    [constant_float_global, nofortranconst_float_global])

  if (any(runtime_ints /= 4)) stop 1
  if (any(runtime_floats /= 1.23)) stop 1
end subroutine

subroutine test_enums  
  use fortran_global_const
  use ISO_C_BINDING
  implicit none
  integer(C_INT), dimension(4), parameter :: compiletime_enums &
    = [ NativeEnum, Alfa, Sierra, Juliet ]

  if (compiletime_enums(1) /= -1) stop 1
  if (compiletime_enums(2) /= 0) stop 1
  if (compiletime_enums(3) /= 1) stop 1

  ! Runtime enums

  if (Foxtrot /= 12345) stop 1
  ! Foxtrot = 2 ! ERROR: Foxtrot is PROTECTED
end subroutine
end program


