! File : fortran_bindc_runme.F90

#include "fassert.h"

program fortran_bindc_runme
  use ISO_C_BINDING
  implicit none

  call test_arrays
  call test_twod_unknown_int

contains

! Test arrays of bound structs and classes
subroutine test_arrays
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  type(XY), pointer :: globalxyarr(:)
  type(XYArray) :: xyarr
  type(XYArray) :: xyarr_ptr
  type(XY) :: tempxy
  integer :: i
  integer(c_short) :: short_array(5) = [ 5_c_short, 40_c_short, 300_c_short, 2000_c_short, 10000_c_short ]
  integer(c_short) :: summed

  ! Get a fortran pointer to the global xy array
  globalxyarr => get_globalXYArray()
  ASSERT(size(globalxyarr) == 3)
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
  ASSERT(tempxy%x == 2)
  ASSERT(tempxy%y == 3)

  ! Allocate a new C array
  xyarr = XYArray(3);
  do i = 1,3
    tempxy%x = 10 * i
    tempxy%y = 10 * i + 1
    call xyarr%setitem(i - 1, tempxy)
  end do

  if (is_cplusplus == 0) then
    ! C assignment: copy xyarr to the object pointed to by xyarr_ptr (i.e. the global array) . This works because the default assingnment traits do a memcpy,
    ! but the C++ class lacks a copy assignment operator.
    xyarr_ptr = xyarr
    
    ASSERT(globalxyarr(1)%x == 10)
    ASSERT(globalxyarr(1)%y == 11)
  end if

  ! Sum a fortran array using a bound(C) function
  summed = sum_array(short_array)
  ASSERT(summed == 12345)

end subroutine

subroutine test_twod_unknown_int
  use fortran_bindc
  use ISO_C_BINDING
  implicit none
  integer(C_INT), target :: test_data(10, 3)
  integer(C_INT) :: i, j, nerrs

  test_data(:,:) = -1
  call twod_unknown_int(test_data, size(test_data, 2))

  nerrs = 0
  do i = 1,10
    do j = 1,3
      if (test_data(i,j) /= i + 10*(j-1)) nerrs = nerrs + 1
    end do
  end do

  if (nerrs /= 0) then
    write(*,*) nerrs, " bad entries:"
    write(*,*) test_data
    stop 1
  end if
end subroutine

end program

