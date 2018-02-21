! File : li_carrays_runme.f90

program li_carrays_runme
  use li_carrays
  use ISO_C_BINDING
  implicit none
  type(XY), pointer :: globalxyarr(:)
  type(XYArray) :: xyarr_ptr
  type(XYArray) :: xyarr, xyarr2
  type(XY) :: tempxy
  integer :: i
  integer(c_short) :: short_array(5) = [ 5, 40, 300, 2000, 10000 ]
  integer(c_short) :: summed

  ! Get a fortran pointer to the global xy array
  globalxyarr => get_globalXYArray()
  if (size(globalxyarr) /= 3) stop 1
  do i = 1,3
    globalxyarr(i)%x = i * 2
    globalxyarr(i)%y = i * 2 + 1
  end do

  ! Global array should have the same values
  write(0,*) "Global values:", get_globalXYArray()

  ! Get a C pointer to the global xy array using a static method
  xyarr_ptr = xyarr_ptr%frompointer(globalxyarr(1))

  ! Check the values: 0 C indexing => 1 Fortran indexing
  tempxy = xyarr_ptr%getitem(0)
  if (tempxy%x /= 2) stop 1
  if (tempxy%y /= 3) stop 1

  ! Allocate a new C array
  xyarr = create_XYArray(3);
  do i = 1,3
    tempxy%x = 10 * i
    tempxy%y = 10 * i + 1
    call xyarr%setitem(i - 1, tempxy)
  end do

  ! C assignment: copy xyarr to the  object pointed to by xyarr_ptr (i.e. the global array) 
  xyarr_ptr = xyarr
  
  if (globalxyarr(1)%x /= 10) stop 1
  if (globalxyarr(1)%y /= 11) stop 1

  ! Sum a fortran array using a bound(C) function
  summed = sum_array(short_array)
  if (summed /= 12345) stop 1

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
