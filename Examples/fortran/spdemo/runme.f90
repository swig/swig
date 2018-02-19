! File : runme.f90

program main

  use ISO_FORTRAN_ENV
  implicit none

  !call test_class()
  call test_spcopy()

contains

subroutine test_class()
  use ISO_FORTRAN_ENV
  use spdemo, only : Foo, create_foo, print_foo => print_crsp
  implicit none
  type(Foo) :: f, f2, f3

  write(0, *) "Constructing..."
  f = create_foo()
  write(0, *) "Setting..."
  call f%set(123.0d0)
  write(0, *) "Clone..."
  f2 = f%clone()
  call print_foo(f2)
  call f%set(234.0d0)
  write(0, *) "Original value should be 234: ", f%get()
  write(0, *) "Cloned value should be 123: ",   f2%get()
  f3 = f2%ref()
  write(0, *) "Reference to f2: ", f3%get()
  call print_foo(f3)
  call f3%set(1.0d0)
  write(0, *) "f2 should be 1: ", f2%get()
  call print_foo(f)

  write(0, *) "Release f"
  call f%release()
  write(0, *) "Release f2"
  call f2%release()
  write(0, *) "Release f3"
  call f3%release()
end subroutine

subroutine test_spcopy()
  use ISO_FORTRAN_ENV
  use spdemo, only : Foo, create_foo, print_foo => print_crsp, use_count
  implicit none
  type(Foo) :: f1, f2

  write(0, *) "Use count should be 0:", use_count(f1)
  write(0, *) "Constructing..."
  f1 = create_foo(1.0d0)
  write(0, *) "Use count should be 1:", use_count(f1)

  write(0, *) "Assigning..."
  f2 = f1
  write(0, *) "Use count should be 2:", use_count(f1)
  write(0, *) "Use count should be 2:", use_count(f2)

  write(0, *) "Cloning..."
  f2 = f1%clone_sp()
  call f2%set(2.0d0)
  write(0, *) "Use count should be 1, val 1:", use_count(f1), f1%get()
  write(0, *) "Use count should be 1, val 2:", use_count(f2), f2%get()

  write(0, *) "Getting reference..."
  f1 = f2%ref()
  write(0, *) "Use count should be 1:", use_count(f1)
  write(0, *) "Use count should be 1:", use_count(f2)

  call f1%release()
  write(0, *) "Use count should be 1:", use_count(f2)
  call f2%release()
  write(0, *) "-- END SUBROUTINE --"
end subroutine

end program

!-----------------------------------------------------------------------------!
! end of spdemo/runme.f90
!-----------------------------------------------------------------------------!
! vim: set ts=2 sw=2 sts=2 tw=129 :
