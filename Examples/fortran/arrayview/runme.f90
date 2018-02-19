! File : runme.f90

program main
  implicit none
  call test_algorithms()
  call test_matview()

contains

subroutine test_algorithms()
  use, intrinsic :: ISO_C_BINDING
  use arrayview, only : reverse, sort, find_sorted, print_array
  implicit none
  integer :: i
  integer(C_INT), dimension(6) :: test_data = (/ -1, 1, 3, 3, 5, 7 /)
  integer(C_INT), dimension(:), allocatable :: alloc_data
  real(C_FLOAT), dimension(4)  :: test_real = (/ 0.1, 1.9, -2.0, 4.0 /)
  character(len=*), parameter :: list_fmt = "(*(i4,"",""))"

  ! Allocate and reverse integer data
  allocate(alloc_data(size(test_data)))
  alloc_data = test_data
  write (0,list_fmt) alloc_data
  call reverse(alloc_data)
  write (0,list_fmt) alloc_data

  call print_array(test_real)
  call sort(test_real)
  call reverse(test_real)
  call print_array(test_real)

  do i = -2,8
    write(0, "(i4,""->"",i4)") i, find_sorted(test_data, i)
  enddo
end subroutine

subroutine test_matview()
  use, intrinsic :: ISO_C_BINDING
  use arrayview, only : print_array
  implicit none
  real(kind=8), dimension(9) :: arr
  real(kind=8), allocatable, dimension(:) :: alloc
  real(kind=8), dimension(3,3) :: mat
  integer :: i, j

  do i = 1,size(arr)
    arr(i) = real(i) + 0.5
  end do

  write(0, *) "Printing array..."
  call print_array(arr)
  write(0, *) "... printed"

  ! Empty array
  write(0, *) "Printing empty..."
  allocate(alloc(0))
  call print_array(alloc)

  ! Matrix slice
  do i = 1,3
    do j = 1,3
      mat(i,j) = (i-1) + 3*(j-1)
    enddo
  enddo

  ! Printing a single column works
  write(0,*) "---- Column access is OK ----"
  do i = 1,3
    write(0, *) "Printing 2D array col ", i, " slice..."
    call print_array(mat(:,i))
  enddo

  ! THIS PRINTS BAD DATA for columns since they're not contiguous
  ! (fortran is row-major)
  write(0,*) "---- Row access is NOT ok ----"

  do i = 1,3
    write(0, *) "Printing 2D array row ", i, " slice..."
    call print_array(mat(i,:))
  enddo

  ! Copy a column to a temporary vector instead
  deallocate(alloc)
  allocate(alloc(3))

  write(0,*) "---- Correct row access ----"
  do i = 1,3
    write(0, *) "Printing 2D array row ", i, " slice..."
    alloc(:) = mat(i,:)
    call print_array(alloc)
  enddo
end subroutine

end program

!-----------------------------------------------------------------------------!
! end of arrayview/runme.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
