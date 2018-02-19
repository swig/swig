! File : runme.f90

program main
  implicit none
  call test_bindc()
  call test_logical()
  call test_strings()
contains

subroutine test_bindc()
  use bindc
  use ISO_C_BINDING
  real(kind=C_DOUBLE), dimension(3) :: inp = (/1.0d0, 2.0d0, 3.0d0/)
  type(Point) :: origin

  call make_point(origin, inp)
  call wrapped_print_point(origin)
  call print_sphere(origin, 1.23d0)
end subroutine

subroutine test_logical()
  use ISO_C_BINDING
  use bindc
  implicit none

  logical(C_BOOL) :: inp, outp
  logical :: ninp, noutp
  inp = .true.
  outp = bound_negation(inp)
  write(0, *) "Should be true:", inp, "; should be false: ", outp
  inp = .false.
  outp = bound_negation(inp)
  write(0, *) "Should be false:", inp, "; should be true: ", outp

  ninp = .true.
  noutp = wrapped_negation(ninp)
  write(0, *) "Should be true:", ninp, "; should be false: ", noutp
  ninp = .false.
  noutp = wrapped_negation(ninp)
  write(0, *) "Should be false:", ninp, "; should be true: ", noutp
end subroutine

subroutine test_strings()
  use ISO_C_BINDING
  use bindc
  implicit none
  integer :: i
  character(len=:), allocatable :: str

  do i = -1, 3
    write(0, *) get_existing_string(i)
  end do

  str = concat("String a", "string b")
  write(0, *) "Concatenated string: '"//str//"'"
end subroutine
end program

!-----------------------------------------------------------------------------!
! end of bindc/runme.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
