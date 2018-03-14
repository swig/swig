! File : runme.f90

program main
  implicit none
  call test_funcs()
  call test_enum()
  call test_consts()

contains

subroutine test_funcs()
  use bare
  implicit none
  real(kind=8) :: temp
  real(kind=8), pointer :: rptr
  call set_something(2, 200.0d0)
  call set_something(1, 10.0d0)
  call set_something(0, 1.0d0)
  write(0, *) "Got ", get_something(0)
  write(0, *) "Got ", get_something(1)

  rptr => get_something_rref(2)
  rptr = 512.0d0

  call get_something_ptr(2, temp)
  write(0, *) "Got ", temp
  call get_something_ref(1, temp)
  write(0, *) "Got ", temp

end subroutine test_funcs

subroutine test_enum()
  use bare
  implicit none
  call print_rgb(RED)
  call print_rgb(GREEN)
  call print_rgb(BLUE)
  call print_rgb(BLACK)
  call print_cmyk(BLACK)
!  call print_color(GREEN)
!  BLACK = BLUE
!  call print_color(BLACK)
end subroutine

subroutine test_consts()
  use bare
  use, intrinsic :: ISO_C_BINDING
  implicit none
  write(0, *) "MY_SPECIAL_NUMBERS ", MY_SPECIAL_NUMBERS
  write(0, *) "octoconst   ", octal_const
  write(0, *) "wrapped_const ", wrapped_const
  write(0, *) "pi is approximately ", approx_pi
  write(0, *) "2pi is approximately ", get_approx_twopi()
  write(0, *) "extern const int is ", get_linked_const_int()
  ! Can't assign these
!   wrapped_const = 2
!   MY_SPECIAL_NUMBERS = 4
end subroutine test_consts
end program

!-----------------------------------------------------------------------------!
! end of barefunctions/runme.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
