! File : runme.f90
module fortran_ops
  use, intrinsic :: ISO_C_BINDING
  implicit none
  public
    
contains
  ! Fortran function that we can export so that
  ! it's available to C code
  function fortran_mul(alfa, bravo) bind(C) &
      result(fresult)
    use, intrinsic :: ISO_C_BINDING
    integer(c_int), intent(in), value :: alfa
    integer(c_int), intent(in), value :: bravo
    integer(c_int) :: fresult

    fresult = alfa * bravo
  end function
end module


program fortran_funptr_runme
  use example
  use fortran_ops
  use, intrinsic :: ISO_C_BINDING
  use ISO_FORTRAN_ENV
  implicit none

  integer, parameter :: STDOUT = OUTPUT_UNIT
  integer(C_INT) :: a = 4
  integer(C_INT) :: b = 3
  procedure(binary_op), pointer :: fptr => null()

  fptr => get_ADD()
  write(STDOUT,*) "SWIG-wrapped C function pointer:", do_op(a, b, fptr)
  fptr => get_SUB()
  write(STDOUT,*) "SWIG-wrapped C function pointer:", do_op(a, b, fptr)
  fptr => get_MUL()
  write(STDOUT,*) "SWIG-wrapped C function pointer:", do_op(a, b, fptr)

  ! Convert Fortran function to C function pointer
  write(STDOUT,*) "C call to Fortran function:", do_op(a, b, fortran_mul)

end program
