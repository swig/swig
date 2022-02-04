! File : runme.f90
program runme
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT

  call run()
contains

subroutine run()
  use example
  use iso_c_binding
  implicit none

  type(Circle)          :: c
  type(Square), target  :: s ! 'target' allows it to be pointed to
  class(Shape), pointer :: sh
  integer(C_INT) :: n_shapes

  ! ----- Object creation -----
    
  write(STDOUT,*) "Creating some objects"
  c = Circle(10.0)
  s = Square(10.0)

  ! ----- Access a static member -----
  write(STDOUT,'(a,i2,a)')"A total of", s%get_nshapes(), " shapes were created"

  ! ----- Member data access -----

  ! Notice how we can do this using functions specific to
  ! the 'Circle' class.
  call c%set_x(20.0)
  call c%set_y(30.0)

  ! Now use the same functions in the base class
  sh => s
  call sh%set_x(-10.0)
  call sh%set_y(  5.0)

  write(STDOUT,*)"Here is their current position:"
  write(STDOUT,'(a,f5.1,a,f5.1,a)')"  Circle = (", c%get_x(), ",", c%get_y(), " )"
  write(STDOUT,'(a,f5.1,a,f5.1,a)')"  Square = (", s%get_x(), ",", s%get_y(), " )"

  ! ----- Call some methods -----

  write(STDOUT,*)"Here are some properties of the shapes:"
  call print_shape(c)
  call print_shape(s)

  ! Call function that takes base class
  write(STDOUT,*)" Circle P/A  = ", surface_to_volume(c)
  write(STDOUT,*)" Square P/A  = ", surface_to_volume(s)

  ! Example of exception handling
  c = circle(-2.0)
  if (ierr /= 0) then
    write(STDOUT,*) "Caught the following error: ", get_serr()
    ierr = 0
  endif

  ! ----- Delete everything -----

  ! Note: this invokes the virtual destructor
  call c%release()
  call s%release()

  n_shapes = c%get_nshapes() 
  write(STDOUT,*) n_shapes, "shapes remain"
  if (n_shapes /= 0) then
    write(STDOUT,*) "Shapes were not freed properly!"
    stop 1
  endif

  write(STDOUT,*) "Goodbye"
end subroutine

subroutine print_shape(s)
  use example, only : Shape
  use iso_c_binding
  implicit none
  class(Shape), intent(in) :: s

  write(STDOUT,*)"  ", s%kind(), ":"
  write(STDOUT,*)"    area      = ",s%area()
  write(STDOUT,*)"    perimeter = ",s%perimeter()
end subroutine

end program

