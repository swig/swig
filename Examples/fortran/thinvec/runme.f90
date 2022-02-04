! File : runme.f90

program main
  use, intrinsic :: ISO_C_BINDING
  use example, only : print_vec, print_offbyone, Vec => ThinVecInt
  use ISO_FORTRAN_ENV
  implicit none

  integer, parameter :: STDOUT = OUTPUT_UNIT
  integer :: i
  type(Vec) :: v
  integer(kind=c_int), dimension(3) :: dummy_data
  integer(kind=c_int), pointer, dimension(:) :: view

  ! This should be a null-op since the underlying pointer is initialized to
  ! null
  call v%release()

  write(STDOUT, *) "Constructing..."
  v = Vec()
  write(STDOUT, *) "Sizing..."
  call v%resize(4)
  call print_vec(v)
  write(STDOUT, *) "Resizing with fill..."
  call v%resize(10, -999)

  write(STDOUT, *) "Setting"
  do i = 0, 7
    call v%set(i, i * 2)
  end do
  call print_vec(v)
  write(STDOUT, *) "Printing with off-by-one"
  call print_offbyone(v)

  ! Pull data from the vector
  view => v%view()
  write(STDOUT, *) "View to ", size(view), "els:", view

  ! Assign a vector
  do i = 1, 3
    dummy_data(i) = i + 23
  end do
  write(STDOUT, *) "Assigning vector", dummy_data
  call v%assign(dummy_data)
  call print_vec(v)

  write(STDOUT, *) "Destroying..."
  call v%release()
end program

!-----------------------------------------------------------------------------!
! end of example/runme.f90
!-----------------------------------------------------------------------------!

