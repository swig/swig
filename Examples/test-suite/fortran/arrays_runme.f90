! File : arrays_runme.f90

program arrays_runme
  use arrays
  use ISO_C_BINDING
  implicit none
  integer(C_INT) :: test_data(10, 3), i, j, nerrs

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

end program

! vim: set ts=2 sw=2 sts=2 tw=129 :
