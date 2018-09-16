! File : runme.f90

program main
  implicit none
  call test_usage()
contains

subroutine test_usage()
  use, intrinsic :: ISO_C_BINDING
  use stdvec
  implicit none
  type(VecDbl) :: v, vref, vcref
  integer :: i
  real(C_DOUBLE), pointer :: vview(:)
  real(C_DOUBLE), allocatable :: local_arr(:)
  real(C_DOUBLE), dimension(4) :: test_dbl = [ 0.1, 1.9, -2.0, 4.0 ]

  ! This should be a null-op since the underlying pointer is initialized to
  ! null
  call v%release()

  write(0, *) "Constructing..."
  v = VecDbl()
  write(0, *) "Sizing..."
  call v%resize(4)
  write(0, *) "Resizing with fill..."
  call v%resize(10, 1.5d0)

  write(0, *) "Setting"
  do i = 0, 7
    call v%set(i, real(i + 1) * 123.0d0)
  end do

  vref = as_reference(v)
  vcref = as_const_reference(v)

  ! Can't run the following line because vcref is const
  ! vview => as_array_ptr(vcref) ! ERROR

  vview => as_array_ptr(vref)
  write(0, *) "pointer:", vview

  write(0, *) "Printing from array pointer"
  call print_view(vview)

  write(0, *) "Printing from test data"
  call print_view(test_dbl)

  write(0, *) "Assigning from test data"
  call vref%assign(test_dbl)

  ! Note that since vref points to v, 'v%back' is the just-pushed value
  write(0, *) "Pushing back"
  call vref%push_back(1.25d0)
  call vref%push_back(v%back())

  write(0, *) "Copying vector of data"
  local_arr = as_array(v)
  write(0, *) "Destroying..."
  call vref%release()
  call vcref%release()
  call v%release()

  write(0, *) "Printing copied data"
  call print_view(local_arr)

  local_arr = make_array()
  write(0, *) "Return-by-value vector:", local_arr
end subroutine
end program

