! File : arrays_runme.f90

program arrays_runme
  implicit none

  call test_arrays

contains
subroutine test_arrays
  use arrays
  use ISO_C_BINDING
  implicit none
  integer(C_INT), target :: test_data(10, 3)
  integer(C_INT) :: i, j, nerrs

  test_data(:,:) = -1
  ! TODO: fix this
  ! call twod_unknown_int(test_data, size(test_data, 2))
  call twod_unknown_int(c_loc(test_data), size(test_data, 2))

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


