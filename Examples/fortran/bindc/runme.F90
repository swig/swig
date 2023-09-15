! File : runme.f90

program main
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT

  call test_example()
  call test_logical()
  call test_strings()
  call test_global()
contains

subroutine test_example()
  use example
  use ISO_C_BINDING
  real(kind=C_DOUBLE), dimension(3) :: inp = (/1.0d0, 2.0d0, 3.0d0/)
  type(Point) :: origin

  call make_point(origin, inp)
  call wrapped_print_point(origin)
  call print_sphere(origin, 1.23d0)
end subroutine

subroutine test_logical()
  use ISO_C_BINDING
  use example
  implicit none

  logical(C_BOOL) :: inp, outp
  logical :: ninp, noutp
  inp = .true.
  outp = bound_negation(inp)
  write(STDOUT, *) "Should be true:", inp, "; should be false: ", outp
  inp = .false.
  outp = bound_negation(inp)
  write(STDOUT, *) "Should be false:", inp, "; should be true: ", outp

  ninp = .true.
  noutp = wrapped_negation(ninp)
  write(STDOUT, *) "Should be true:", ninp, "; should be false: ", noutp
  ninp = .false.
  noutp = wrapped_negation(ninp)
  write(STDOUT, *) "Should be false:", ninp, "; should be true: ", noutp
end subroutine

subroutine test_strings()
  use ISO_C_BINDING
  use example
  implicit none
  integer :: i
  character(len=:), allocatable :: str

  do i = -1, 3
    write(STDOUT, *) get_existing_string(i)
  end do

  ! Note: automatic allocation is allowed in Fortran 2003, but GCC tends to
  ! produce spurious warnings about "maybe uninitialized".
  !str = concat("String a", "string b")
  ! Alternatively you can explicitly allocate the string:
  allocate(str, source=concat("String a", "string b"))
  write(STDOUT, *) "Concatenated string: '"//str//"'"
end subroutine

subroutine test_global()
  use ISO_C_BINDING
  use example
  implicit none
  my_global_var = 2
  write(STDOUT, "(/a, i2/)") "Global variable: ", get_my_global_var()

end subroutine

end program

!-----------------------------------------------------------------------------!
! end of example/runme.f90
!-----------------------------------------------------------------------------!

