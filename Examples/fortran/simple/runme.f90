! File : runme.f90
program simple_runme
  use simple

  implicit none

  integer :: x, y, g

  ! Call our gcd() function
  x = 42
  y = 105
  g = gcd(x, y)
  write(*,'(a, i2, a, i3, a, i2)')"The gcd of ", x, " and ", y, " is ", g

  ! Manipulate the Foo global variable

  ! Output its current value
  write(*,*)"Foo = ", get_Foo()

  ! Change its value
  call set_Foo(3.1415926_8)

  write(*,*)"Foo = ", get_Foo()
end program
! vim: set ts=2 sw=2 sts=2 tw=129 :
