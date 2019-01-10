! File : runme.f90
module fortran_ops
  use, intrinsic :: ISO_C_BINDING
  implicit none
  public
    
  abstract interface
    ! Interface corresponding to the C typedef "BinaryOp"
    function binary_op(aa, bb) bind(C)  result(cc)
      use, intrinsic :: ISO_C_BINDING
      integer(C_INT), intent(in), value :: aa
      integer(C_INT), intent(in), value :: bb
      integer(C_INT) :: cc
    end function
  end interface
  
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
  implicit none

  integer(C_INT) :: a = 4
  integer(C_INT) :: b = 3
  type(C_FUNPTR) :: temp_funptr
  procedure(binary_op), pointer :: my_ffunc => null()

  write(*,*) "SWIG-wrapped C function pointer:", do_op(a,b,add)
  write(*,*) "SWIG-wrapped C function pointer:", do_op(a,b,sub)
  write(*,*) "SWIG-wrapped C function pointer:", do_op(a,b,mul)

  ! Convert Fortran function to C function pointer
  temp_funptr = c_funloc(fortran_mul)
  write(*,*) "C call to Fortran function:", do_op(a,b,temp_funptr)

  ! Convert C function pointer to a Fortran function pointer
  call c_f_procpointer(add, my_ffunc)
  write(*,*) "Fortran direct call to C function:", my_ffunc(a,b)

end program
