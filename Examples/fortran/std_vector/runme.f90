! File : runme.f90

program main
  implicit none
  call test_usage()
contains

subroutine test_usage()
  use, intrinsic :: ISO_C_BINDING
  use stdvec
  implicit none
  real(C_DOUBLE), allocatable :: local_arr(:)
  real(C_DOUBLE), dimension(4) :: test_dbl = [ 0.1, 1.9, -2.0, 4.0 ]

  ! Turn a std::vector<double> return value into an allocatable fortran array
  local_arr = make_array()
  write(0, *) "Created array:", local_arr

  ! Turn a fortran array into a vector (requires a copy)
  write(0, *) "Printing from test data"
  call print_vec(test_dbl)

  ! Directly print the fortran data (no copy)
  call print_view(test_dbl)

end subroutine
end program

