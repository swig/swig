! File : runme.f90
program example_runme
  use example
  use ISO_FORTRAN_ENV
  implicit none

  integer, parameter :: STDOUT = OUTPUT_UNIT
  integer :: x, y, g

  ! Call our gcd() function
  x = 42
  y = 105
  g = gcd(x, y)
  write(STDOUT,'(a, i2, a, i3, a, i2)') "The gcd of ", x, " and ", y, " is ", g

  ! Manipulate the Foo global variable

  ! Output its current value
  write(STDOUT,*) "Foo = ", get_Foo()

  ! Change its value
  call set_Foo(3.1415926_8)

  write(STDOUT,*) "Foo = ", get_Foo()
end program

