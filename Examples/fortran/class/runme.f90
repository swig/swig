! File : runme.f90
program class_runme
  use example

  implicit none

  type(Circle) :: c
  type(Square) :: s

  ! Create objects
  write(*,*) "Creating some objects"
  c = create_circle(10.0_8)
  s = create_square(10.0_8)

  ! Access static member
  write(*,'(a,i2,a)')"A total of", s%get_nshapes(), " shapes were created"

  ! Member data access. TODO: This is done now using the move method, but since
  ! the members are public, accessors should be generated automatically
  call c%move(20.0_8, 30.0_8)
  call s%move(-10.0_8, 5.0_8)

  ! Need accessors for public members to be able to do this
  write(*,*)"Here is their current position:"
  write(*,*)"  Circle = (", c%get_x(), ",", c%get_y(), " )"

  ! Call some methods
  write(*,*)"Here are some properties of the shapes:"
  write(*,*)"  Circle:"
  write(*,*)"    area    = ",c%area()
  write(*,*)"    perimeter = ",c%perimeter()
  write(*,*)"  Square:"
  write(*,*)"    area    = ",s%area()
  write(*,*)"    perimeter = ",s%perimeter()

  ! Call function that takes base class
  write(*,*)" Circle P/A  = ", surface_to_volume(c)
  write(*,*)" Square P/A  = ", surface_to_volume(s)

  ! Example of exception handling
  c = create_circle(-2.0d0)
  if (ierr /= 0) then
    write(*,*) "Caught the following error: ", get_serr()
    ierr = 0
  endif

  call c%release()
  call s%release()

  ! Check n shapes by calling a static method
  write(*,*)c%get_nshapes(), "shapes remain"
  write(*,*)"Goodbye"
end program
! vim: set ts=2 sw=2 sts=2 tw=129 :
