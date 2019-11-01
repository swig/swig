! File : director_int_runme.F90

#include "fassert.h"

module director_int_mod
  use, intrinsic :: ISO_C_BINDING
  use ISO_FORTRAN_ENV
  use director_int, only : Base
  implicit none

 type, extends(Base), public :: MyDerived
   integer(C_INT) :: multiply_by = 1
   integer(C_INT) :: add_to = 0
 contains
  procedure :: apply => MyDerived_apply
 end type MyDerived
  
contains

function MyDerived_apply(self, x) &
result(myresult)
use, intrinsic :: ISO_C_BINDING
class(MyDerived), intent(in) :: self
integer(C_INT), intent(in) :: x
integer(C_INT) :: myresult

myresult = x * self%multiply_by + self%add_to
end function

end module

program director_int_runme
  call test_director_int
contains

subroutine test_director_int
  use director_int
  use director_int_mod
  use, intrinsic :: ISO_C_BINDING
  type(MyDerived), target :: myclass
  class(Base), pointer :: baseptr => NULL()
  class(Base), allocatable :: alloc

  ! Allocate and set up callbacks for base class
  call swig_initialize(myclass, source=Base())
  myclass%multiply_by = 2
  myclass%add_to = 1

  ! Direct Fortran call
  ASSERT(myclass%apply(10_c_int) == 21_c_int)
  ! Call through C director
  ASSERT(apply(myclass, 10_c_int) == 21_c_int)
  ! Call through C via base pointer
  baseptr => myclass
  ASSERT(apply(baseptr, 10_c_int) == 21_c_int)

  myclass%multiply_by = 3
  ASSERT(apply(baseptr, 10_c_int) == 31_c_int)

  call myclass%release()

  ! Allocate a C++ daughter class and call it as well
  allocate(alloc, source=Base())
  ASSERT(apply(alloc, 2_c_int) == 4_c_int)
  call alloc%release()
  deallocate(alloc)

  allocate(alloc, source=Derived())
  ASSERT(apply(alloc, 2_c_int) == 6_c_int)
  call alloc%release()
  deallocate(alloc)

end subroutine
end program


