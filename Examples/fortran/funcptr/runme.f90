! File : runme.f90
module ops
  use, intrinsic :: ISO_C_BINDING
  implicit none
  public

  ! Declare Fortran interface so that we can get a Fortran pointer to a C function
  abstract interface
    function binary_op(aa, bb)  BIND(C)  result(cc)
      use, intrinsic :: ISO_C_BINDING
      integer(C_INT), intent(in), value :: aa
      integer(C_INT), intent(in), value :: bb
      integer(C_INT) :: cc
    end function
  end interface
contains
  function fortfunc(alfa, bravo) BIND(C) &
      result(fresult)
    use, intrinsic :: ISO_C_BINDING
    integer(c_int), intent(in), value :: alfa
    integer(c_int), intent(in), value :: bravo
    integer(c_int) :: fresult

    fresult = alfa**bravo
  end function

end module

program test_function_args
  use, intrinsic :: ISO_C_BINDING
  implicit none

  call test()

contains
subroutine test()
  use funcptr, only : do_op, add, sub, mul, set_funcvar, get_funcvar
  use ops, only : binary_op, fortfunc
  use, intrinsic :: ISO_C_BINDING
  implicit none

  integer(C_INT) :: a = 4
  integer(C_INT) :: b = 3
  type(C_FUNPTR) :: temp_funptr
  procedure(binary_op), pointer :: my_ffunc => null()
  

  write(*,*) "Trying some C callback functions"
  write(*,*) "  a    = ", a
  write(*,*) "  b    = ", b
  write(*,*) "  ADD(a,b) = ", do_op(a,b,add)
  write(*,*) "  SUB(a,b) = ", do_op(a,b,sub)
  write(*,*) "  MUL(a,b) = ", do_op(a,b,mul)
  write(*,*) "  POW(a,b) = ", do_op(a,b,c_funloc(fortfunc))

  ! Get the original function pointer, which should be add
  temp_funptr = get_funcvar()
  call c_f_procpointer(temp_funptr, my_ffunc)
  write(*,*) "   *ADD(a,b) = ", my_ffunc(a,b)

  ! Set the function pointer to a different function
  call set_funcvar(sub)
  temp_funptr = get_funcvar()
  call c_f_procpointer(temp_funptr, my_ffunc)
  write(*,*) "   *SUB(a,b) = ", my_ffunc(a, b)
end subroutine
end program
! vim: set ts=2 sw=2 sts=2 tw=129 :
