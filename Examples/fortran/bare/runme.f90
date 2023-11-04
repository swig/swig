! File : runme.f90

program main
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT

  call test_funcs()
  call test_enum()
  call test_consts()

contains

subroutine test_funcs()
  use example
  implicit none
  real(kind=8) :: temp
  real(kind=8), pointer :: rptr
  call set_something(2, 200.0d0)
  call set_something(1, 10.0d0)
  call set_something(0, 1.0d0)
  write(STDOUT, *) "Got ", get_something(0)
  write(STDOUT, *) "Got ", get_something(1)

  rptr => get_something_rref(2)
  rptr = 512.0d0

  call get_something_ref(1, temp)
  write(STDOUT, *) "Got ", temp

end subroutine test_funcs

subroutine test_enum()
  use example
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
  use example
  use, intrinsic :: ISO_C_BINDING
  implicit none
  write(STDOUT, *) "MY_SPECIAL_NUMBERS ", MY_SPECIAL_NUMBERS
  write(STDOUT, *) "octoconst   ", octal_const
  write(STDOUT, *) "wrapped_const ", wrapped_const
  write(STDOUT, *) "pi is approximately ", approx_pi
  write(STDOUT, *) "2pi is approximately ", get_approx_twopi()
  write(STDOUT, *) "extern const int is ", get_linked_const_int()
  write(STDOUT, *) so_excited
  ! Can't assign these
!   wrapped_const = 2
!   MY_SPECIAL_NUMBERS = 4
end subroutine test_consts
end program

!-----------------------------------------------------------------------------!
! end of examplefunctions/runme.f90
!-----------------------------------------------------------------------------!

