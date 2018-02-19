! File : runme.f90

program main
  implicit none
  call test_usage()
contains

subroutine test_usage()
  use, intrinsic :: ISO_C_BINDING
  use stdvec, only : make_view => make_const_viewdbl, &
    print_view => print_viewdbl, VecDbl, get_vec => get_vecdbl, &
    create_vecdbl, as_array_ptr, make_array
  implicit none
  type(VecDbl) :: v
  integer :: i
  real(C_DOUBLE), pointer :: vview(:)
  real(C_DOUBLE), allocatable :: local_vec(:)
  real(C_DOUBLE), dimension(4)  :: test_dbl = [ 0.1, 1.9, -2.0, 4.0 ]

  ! This should be a null-op since the underlying pointer is initialized to
  ! null
  call v%release()

  write(0, *) "Constructing..."
  v = create_vecdbl()
  write(0, *) "Sizing..."
  call v%resize(4)
  write(0, *) "Resizing with fill..."
  call v%resize(10, 1.5d0)

  write(0, *) "Setting"
  do i = 0, 7
    call v%set(i, real(i + 1) * 123.0d0)
  end do

  vview => make_view(v)

  write(0, *) "pointer:", vview

  write(0, *) "Printing from array pointer"
  call print_view(vview)

  vview => as_array_ptr(v)
  write(0, *) "also as array pointer:", vview

  write(0, *) "Printing from test data"
  call print_view(test_dbl)

  write(0, *) "Copying vector of data"
  local_vec = get_vec(v)
  write(0, *) "Destroying..."
  call v%release()

  write(0, *) "Printing copied data"
  call print_view(local_vec)

  local_vec = make_array()
  write(0, *) "Return-by-value vector:", local_vec
end subroutine
end program
! vim: set ts=2 sw=2 sts=2 tw=129 :
