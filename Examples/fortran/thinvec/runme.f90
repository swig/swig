! File : runme.f90

program main
  use ISO_FORTRAN_ENV
  use, intrinsic :: ISO_C_BINDING
  use thinvec, only : print_vec, print_offbyone, Vec => ThinVecInt, &
    create_vec => create_ThinVecInt
  implicit none
  integer :: i
  type(Vec) :: v
  integer(kind=c_int), dimension(3) :: dummy_data
  integer(kind=c_int), pointer, dimension(:) :: view

  ! This should be a null-op since the underlying pointer is initialized to
  ! null
  call v%release()

  write(0, *) "Constructing..."
  v = create_vec()
  write(0, *) "Sizing..."
  call v%resize(4)
  call print_vec(v)
  write(0, *) "Resizing with fill..."
  call v%resize(10, -999)

  write(0, *) "Setting"
  do i = 0, 7
    call v%set(i, i * 2)
  end do
  call print_vec(v)
  write(0, *) "Printing with off-by-one"
  call print_offbyone(v)

  ! Pull data from the vector
  view => v%view()
  write(0, *) "View to ", size(view), "els:", view

  ! Assign a vector
  do i = 1, 3
    dummy_data(i) = i + 23
  end do
  write(0, *) "Assigning vector", dummy_data
  call v%assign(dummy_data)
  call print_vec(v)

  write(0, *) "Destroying..."
  call v%release()
end program

!-----------------------------------------------------------------------------!
! end of thinvec/runme.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
