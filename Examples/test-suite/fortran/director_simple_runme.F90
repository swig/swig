! File : director_simple_runme.F90

#include "fassert.h"

module director_simple_mod
  use, intrinsic :: ISO_C_BINDING
  use ISO_FORTRAN_ENV
  use director_simple, only : IntBase, BoolBase
  implicit none

  integer :: call_count

  type, extends(IntBase), public :: MyIntDerived
    integer(C_INT) :: multiply_by = 1
    integer(C_INT) :: add_to = 0
  contains
    procedure :: apply => MyIntDerived_apply
  end type MyIntDerived
   
  type, extends(BoolBase), public :: MyBoolDerived
    integer :: call_count = 0
  contains
    procedure :: apply => MyBoolDerived_apply
  end type MyBoolDerived
   
contains
 
function MyIntDerived_apply(self, x) &
  result(myresult)
  use, intrinsic :: ISO_C_BINDING
  class(MyIntDerived), intent(in) :: self
  integer(C_INT), intent(in) :: x
  integer(C_INT) :: myresult

  myresult = x * self%multiply_by + self%add_to
end function

function MyBoolDerived_apply(self, a, b) &
  result(myresult)
  use, intrinsic :: ISO_C_BINDING
  class(MyBoolDerived), intent(in) :: self
  logical, intent(in) :: a
  logical, intent(in) :: b
  logical :: myresult
  
  myresult = a .or. b
  call_count = call_count + 1
end function
end module

program director_simple_runme
  call test_director_int
  call test_director_bool
contains

subroutine test_director_int
  use director_simple
  use director_simple_mod
  use, intrinsic :: ISO_C_BINDING
  type(MyIntDerived), target :: myclass
  class(IntBase), pointer :: baseptr => NULL()
  class(IntBase), allocatable :: alloc

  ! Allocate and set up callbacks for IntBase class
  call swig_initialize(myclass, source=IntBase())
  myclass%multiply_by = 2
  myclass%add_to = 1

  ! Direct Fortran call
  ASSERT(myclass%apply(10_c_int) == 21_c_int)
  ! Call through C director
  ASSERT(apply(myclass, 10_c_int) == 21_c_int)
  ! Call through C via IntBase pointer
  baseptr => myclass
  ASSERT(apply(baseptr, 10_c_int) == 21_c_int)

  myclass%multiply_by = 3
  ASSERT(apply(baseptr, 10_c_int) == 31_c_int)

  call myclass%release()

  ! Allocate a C++ daughter class and call it as well
  allocate(alloc, source=IntBase())
  ASSERT(apply(alloc, 2_c_int) == 4_c_int)
  call alloc%release()
  deallocate(alloc)

  allocate(alloc, source=IntDerived())
  ASSERT(apply(alloc, 2_c_int) == 6_c_int)
  call alloc%release()
  deallocate(alloc)

end subroutine

subroutine test_director_bool
  use director_simple
  use director_simple_mod
  use, intrinsic :: ISO_C_BINDING
  type(MyBoolDerived), target :: myclass

  ! Allocate and set up callbacks for BoolBase class
  call swig_initialize(myclass, source=BoolBase())

  ! Direct Fortran call
  call_count = 0
  ASSERT(myclass%apply(.true., .false.))
  ASSERT(.not. myclass%apply(.false., .false.))
  ! Call through C director
  ASSERT(apply(myclass, .true., .false.))
  ASSERT(.not. apply(myclass, .false., .false.))
  ASSERT(call_count == 4)

  call myclass%release()

end subroutine
end program


