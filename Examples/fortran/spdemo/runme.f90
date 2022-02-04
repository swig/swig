! File : runme.f90

program main
  use ISO_FORTRAN_ENV
  implicit none
  integer, parameter :: STDOUT = OUTPUT_UNIT

  call test_class()
  call test_spcopy()

contains

subroutine test_class()
  use example, only : Foo, print_foo => print_crsp
  implicit none
  type(Foo) :: f, f2, f3

  write(STDOUT, *) "Constructing..."
  f = foo()
  write(STDOUT, *) "Setting..."
  call f%set(123.0d0)
  write(STDOUT, *) "Clone..."
  f2 = f%clone()
  call print_foo(f2)
  call f%set(234.0d0)
  write(STDOUT, *) "Original value should be 234: ", f%get()
  write(STDOUT, *) "Cloned value should be 123: ",   f2%get()
  f3 = f2%ref()
  write(STDOUT, *) "Reference to f2: ", f3%get()
  call print_foo(f3)
  call f3%set(1.0d0)
  write(STDOUT, *) "f2 should be 1: ", f2%get()
  call print_foo(f)

  write(STDOUT, *) "Release f"
  call f%release()
  write(STDOUT, *) "Release f2"
  call f2%release()
  write(STDOUT, *) "Release f3"
  call f3%release()
end subroutine

subroutine test_spcopy()
  use example, only : Foo, print_foo => print_crsp, use_count
  implicit none
  type(Foo) :: f1, f2

  write(STDOUT, *) "Use count should be 0:", use_count(f1)
  write(STDOUT, *) "Constructing..."
  f1 = foo(1.0d0)
  write(STDOUT, *) "Use count should be 1:", use_count(f1)

  write(STDOUT, *) "Assigning..."
  f2 = f1
  write(STDOUT, *) "Use count should be 2:", use_count(f1)
  write(STDOUT, *) "Use count should be 2:", use_count(f2)

  write(STDOUT, *) "Self-assigning should change nothing..."
  f2 = f2
  write(STDOUT, *) "Use count should be 2:", use_count(f2)

  write(STDOUT, *) "Cloning..."
  f2 = f1%clone_sp()
  call f2%set(2.0d0)
  write(STDOUT, *) "Use count should be 1, val 1:", use_count(f1), f1%get()
  write(STDOUT, *) "Use count should be 1, val 2:", use_count(f2), f2%get()

  write(STDOUT, *) "Getting reference..."
  f1 = f2%ref()
  write(STDOUT, *) "Use count should be 1:", use_count(f1)
  write(STDOUT, *) "Use count should be 1:", use_count(f2)
  call f2%release()
  write(STDOUT, *) "Use count should be 1:", use_count(f1)
  call f1%release()
  write(STDOUT, *) "-- END SUBROUTINE --"
end subroutine

end program

!-----------------------------------------------------------------------------!
! end of example/runme.f90
!-----------------------------------------------------------------------------!

